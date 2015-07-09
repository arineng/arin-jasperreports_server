#d_org_roles == Class: jasperreports_server::config
#
# Install and configures JasperReports Server
#
# === Parameters
#
# === Examples
#
# === Authors
#
# Steven Bambling <smbambling@arin.net>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class jasperreports_server::config (
  $external_ad_auth     = $jasperreports_server::external_ad_auth,
  $ad_connection_source = $jasperreports_server::ad_connection_source,
  $ad_userdn            = $jasperreports_server::ad_userdn,
  $ad_password          = $jasperreports_server::ad_password,
  $ad_group_base        = $jasperreports_server::ad_group_base,
  $ad_user_base         = $jasperreports_server::ad_user_base,
  $ad_org_roles         = $jasperreports_server::ad_org_roles,
) {

  if ( $external_ad_auth == true ) {
    #Install Auth-LDAP.xml file
    file { 'External Auth XML':
      ensure  => present,
      path    => "${jasperreports_server::buildomatic_appserverdir}/webapps/jasperserver/WEB-INF/applicationContext-externalAuth-LDAP.xml",
      owner   => 'tomcat',
      group   => 'tomcat',
      mode    => '0770',
      content => template('jasperreports_server/applicationContext-externalAuth-LDAP.xml.erb'),
    }
  }
}
