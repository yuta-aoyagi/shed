# https://wiki.mozilla.org/CA/Included_Certificates ->
# https://ccadb-public.secure.force.com/mozilla/IncludedCACertificateReport
step1:
	openssl x509 -sha256 -fingerprint <isrgrootx1.pem | \
	  tr -d : | \
	  grep 96BCEC06264976F37460779ACF28C5A7CFE8A3C0AAE11A8FFCEE05C0BDDF08C6

step2:
	sh https.sh httpbin.org GET\ /headers 2>&1 >hb.txt | \
	  grep "^verify return:[^0]"
