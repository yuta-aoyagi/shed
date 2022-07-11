# Google search `ca-certificates mozilla` ->
# https://wiki.mozilla.org/CA/Included_Certificates ->
# https://ccadb-public.secure.force.com/mozilla/IncludedCACertificateReport
step1:
	openssl x509 -sha256 -fingerprint <isrgrootx1.pem | \
	  tr -d : | \
	  grep 96BCEC06264976F37460779ACF28C5A7CFE8A3C0AAE11A8FFCEE05C0BDDF08C6
