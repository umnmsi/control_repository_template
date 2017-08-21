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
  include profile::mysql

  $ssl_certs_dir = $::apache::params::ssl_certs_dir

  file { "${ssl_certs_dir}/${fqdn}.crt":
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/ssl_certs/${fqdn}.crt",
    notify => Service['httpd'],
  }
  file { "${ssl_certs_dir}/${fqdn}.key":
    owner     => 'root',
    group     => 'root',
    mode      => '0640',
    content   => lookup("website_ssl_keys.'${fqdn}'"),
    show_diff => false,
    notify    => Service['httpd'],
  }

  apache::vhost { $fqdn:
    servername => $fqdn,
    ssl        => true,
    port       => 443,
    ip_based   => true,
    ip         => $ip,
    ssl_cert   => "${ssl_certs_dir}/${fqdn}.crt",
    ssl_key    => "${ssl_certs_dir}/${fqdn}.key",
    docroot    => "/var/www/${fqdn}",
    block      => ['scm'],
  }

  apache::vhost { "${fqdn}-http":
    servername      => $fqdn,
    ssl             => false,
    port            => 80,
    ip_based        => true,
    ip              => $ip,
    docroot         => '/var/www/nonssl_redirect_empty_docroot',
    redirect_status => 'permanent',
    redirect_dest   => "https://${fqdn}/",
  }
}
