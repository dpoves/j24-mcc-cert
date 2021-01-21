# MediaCentral Cloud UX server certificate generation script

Certificates from a 3rd party Certificate Authority requires the system to generate a certificate key file (.key) and a Certificate Signing Request file (.csr).

Although the steps are very simple, having to do this repeatedly is tedious and prone to mistakes. This script addresses this.

## j24-mcc-cert_option1.sh

Configuration can be edited via a menu.

## j24-mcc-cert_option2.sh

The configuration can be edited as a file. Just execute the script and it will generate a configuration file that can be edited. The domain name to generate the certificates from can be given as an argument.