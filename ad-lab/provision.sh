#!/bin/bash
# Provision a throwaway Samba AD domain (lab.local) with two intentionally
# roastable accounts, then run the DC in the foreground. Idempotent: the
# domain is only provisioned the first time the container starts.
set -euo pipefail

REALM="LAB.LOCAL"
DOMAIN="LAB"
DCPASS="LabAdmin123!"
PRIV="/var/lib/samba/private"

if [ ! -f "$PRIV/sam.ldb" ]; then
  echo "[*] Provisioning domain $REALM ..."
  rm -f /etc/samba/smb.conf
  samba-tool domain provision \
    --use-rfc2307 --realm "$REALM" --domain "$DOMAIN" \
    --server-role=dc --dns-backend=SAMBA_INTERNAL \
    --adminpass "$DCPASS"

  echo "[*] Seeding a Kerberoastable service account (SPN set, weak password)"
  samba-tool user create svc_mssql 'Summer2023!'
  samba-tool spn add MSSQLSvc/sql.lab.local:1433 svc_mssql

  echo "[*] Seeding an AS-REP-roastable user (Kerberos pre-auth disabled)"
  samba-tool user create jdoe 'Autumn2024!'
  # 4194816 = NORMAL_ACCOUNT (512) | DONT_REQUIRE_PREAUTH (4194304)
  ldbmodify -H "$PRIV/sam.ldb" <<'LDIF'
dn: CN=jdoe,CN=Users,DC=lab,DC=local
changetype: modify
replace: userAccountControl
userAccountControl: 4194816
LDIF

  echo "[*] Injecting a realistic privesc misconfig: svc_mssql granted DS-Replication"
  echo "    rights directly on the domain object (common real-world pattern: a"
  echo "    backup/sync tool's service account over-delegated DCSync rights)."
  SVC_SID=$(samba-tool user show svc_mssql | awk -F': ' '/^objectSid/{print $2}')
  samba-tool dsacl set --objectdn="DC=lab,DC=local" \
    --sddl="(OA;;CR;1131f6aa-9c07-11d1-f79f-00c04fc2dcd2;;${SVC_SID})(OA;;CR;1131f6ad-9c07-11d1-f79f-00c04fc2dcd2;;${SVC_SID})"

  echo "[*] Also granting svc_mssql 'User-Force-Change-Password' on Administrator"
  echo "    (common real-world pattern: a helpdesk/service delegation that was"
  echo "    scoped too broadly and ended up covering a privileged account)."
  samba-tool dsacl set --objectdn="CN=Administrator,CN=Users,DC=lab,DC=local" \
    --sddl="(OA;;CR;00299570-246d-11d0-a768-00aa006e0529;;${SVC_SID})"

  echo "[*] Done. DA password is $DCPASS (Administrator). Lab accounts seeded."
fi

echo "[*] Starting Samba AD DC in the foreground ..."
exec samba -i -s /etc/samba/smb.conf
