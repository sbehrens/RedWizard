#!/bin/sh

GOPHISH_ROOT="/opt/gophish"
GOPHISHDIR="/opt/gophish"
CONTACT_EMAIL=info@meechum-migration.com

rm -rf "${GOPHISH_ROOT}" >/dev/null 2>&1

git clone https://github.com/gophish/gophish "${GOPHISH_ROOT}"
cd "${GOPHISH_ROOT}"

# Additional OPSEC patches may be applied here
# git patch /tmp/opsec.patch

wget -q -c "https://golang.org/dl/go1.17.7.linux-amd64.tar.gz"
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.7.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin

sed -i "s/\"contact_address\": \"\"/\"contact_address\": \"$CONTACT_EMAIL\"/g" $GOPHISHDIR/config.json
sed -i 's/X-Gophish-Contact/X-Contact/g' $GOPHISHDIR/models/email_request_test.go
sed -i 's/X-Gophish-Contact/X-Contact/g' $GOPHISHDIR/models/maillog.go
sed -i 's/X-Gophish-Contact/X-Contact/g' $GOPHISHDIR/models/maillog_test.go
sed -i 's/X-Gophish-Contact/X-Contact/g' $GOPHISHDIR/models/email_request.go
sed -i 's/Default Email from Gophish/test SMTP configuration/g' $GOPHISHDIR/controllers/api/util.go
sed -i 's/your gophish configuration/test email configuration/g' $GOPHISHDIR/controllers/api/util.go
sed -i 's/send some phish/check all configurations for errors and logfiles/g' $GOPHISHDIR/controllers/api/util.go

# Stripping X-Gophish-Signature
sed -i 's/X-Gophish-Signature/X-Signature/g' $GOPHISHDIR/webhook/webhook.go

# Changing servername
sed -i 's/const ServerName = "gophish"/const ServerName = "IGNORE"/' $GOPHISHDIR/config/config.go

# Changing rid value
sed -i 's/const RecipientParameter = "rid"/const RecipientParameter = "keyname"/g' $GOPHISHDIR/models/campaign.go

cp -f /tmp/404.html $GOPHISHDIR/templates/
cp -f /tmp/phish.go $GOPHISHDIR/controllers/

go get -v && go build -v
