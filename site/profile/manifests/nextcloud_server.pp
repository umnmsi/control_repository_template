# == Class: profile::nextcloud_server
#
# Profile for NextCloud server instances.
#
# === Parameters
#
# [*fqdn*]
#   The fully qualified domain name of this NextCloud.
# [*ip*]
#   The IP address where this NextCloud will be hosted.
#
class profile::nextcloud_server (
  String $fqdn = $trusted['certname'],
  String $ip   = $facts['ipaddress'],
) {
  include profile::apache_webserver
  include profile::php



  apache::vhost { $fqdn:
    servername => $fqdn,
    ssl        => true,
    port       => 443,
    ip_based   => true,
    ip         => $ip,
    # ssl_cert => "/etc/ssl/${fqdn}.crt",
    # ssl_key  => "/etc/ssl/private/${fqdn}.key",
    docroot    => "/var/www/${fqdn}",
    block      => ['scm'],
  }

  apache::vhost { "${fqdn}-http":
    servername      => $fqdn,
    ssl             => false,
    port            => 80,
    ip_based        => true,
    ip              => $ip,
    redirect_status => 'permanent',
    redirect_dest   => "https://${fqdn}/",
  }
}
