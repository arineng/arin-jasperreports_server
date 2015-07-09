# JasperReports Server Parameters
class jasperreports_server::params {
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
}
