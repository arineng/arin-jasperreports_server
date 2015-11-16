# JasperReports Server Parameters
class jasperreports_server::params {
  $buildomatic_user = 'root'
  $buildomatic_appservertype = 'tomcat8'
  $buildomatic_appserverdir = '/opt/apache-tomcat'
  $buildomatic_catalina_home = undef
  $buildomatic_catalina_base = undef
  $buildomatic_jboss_profile = undef
  $buildomatic_dbtype = 'postgresql'
  $buildomatic_dbhost = 'localhost'
  $buildomatic_dbusername = 'postgres'
  $buildomatic_dbpassword = 'changeme'
  $buildomatic_extras = {}
  $ad_connection_source = 'ldaps://example.dev:636'
  $ad_userdn = 'jaspertest@example'
  $ad_password = 'passwordblah'
  $ad_group_base = 'OU=Jaspersoft,OU=Groups,DC=example,DC=dev'
  $ad_user_base = 'OU=Users,DC=example,DC=dev'
  $ad_org_roles = [ 'jasperGroup1', 'jasperGroup2', ]
  $sql_validation = true
}
