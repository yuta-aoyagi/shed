# Google search `ca-certificates mozilla` ->
# https://wiki.mozilla.org/CA/Included_Certificates ->
# https://ccadb-public.secure.force.com/mozilla/IncludedCACertificateReport
step1:
	openssl x509 -sha256 -fingerprint <isrgrootx1.pem | \
	  tr -d : | \
	  grep 96BCEC06264976F37460779ACF28C5A7CFE8A3C0AAE11A8FFCEE05C0BDDF08C6

# The example below saves the HTTP response to a file, and scans the message
# from `openssl s_client`, to check the TLS verification succeeded or not.
step2:
	sh https.sh httpbin.org GET\ /headers 2>&1 >hb.txt | \
	  grep "^verify return:[^0]"

# Another examples below show the behavior difference, on a certain, quite old
# environment. On such environment, step3 outputs `verify return:0` as the
# verification failure.
HOST = valid-isrgrootx1.letsencrypt.org
REQ = GET\ /images/LE_badge_color.svg
RES_FILE = LE_badge_color_response.dat

step3:
	sh https.sh "$(HOST)" $(REQ) >/dev/null

step4:
	sh https.sh "$(HOST)" $(REQ) -CAfile isrgrootx1.pem >$(RES_FILE)
