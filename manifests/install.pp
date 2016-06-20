# == Class: jasperreports_server::install 

# Install and configures JasperReports Server 
#
# === Parameters
#
# [*pkg_version*]
#   server version
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
class jasperreports_server::install (
  $pkg_version               = undef,
  $source_url                = undef,
  $nexus_url                 = $jasperreports_server::nexus_url,
  $nexus_repository          = $jasperreports_server::nexus_repository,
  $nexus_gav                 = $jasperreports_server::nexus_gav,
  $nexus_packaging           = $jasperreports_server::nexus_packaging,
  $nexus_classifier          = $jasperreports_server::nexus_classifier,
  $buildomatic_user          = $jasperreports_server::buildomatic_user,
  $buildomatic_appservertype = $jasperreports_server::buildomatic_appservertype,
  $buildomatic_appserverdir  = $jasperreports_server::buildomatic_appserverdir,
  $buildomatic_catalina_home = $jasperreports_server::buildomatic_catalina_home,
  $buildomatic_catalina_base = $jasperreports_server::buildomatic_catalina_base,
  $buildomatic_jboss_profile = $jasperreports_server::buildomatic_jboss_profile,
  $buildomatic_dbtype        = $jasperreports_server::buildomatic_dbtype,
  $buildomatic_dbhost        = $jasperreports_server::buildomatic_dbhost,
  $buildomatic_dbusername    = $jasperreports_server::buildomatic_dbusername,
  $buildomatic_dbpassword    = $jasperreports_server::buildomatic_dbpassword,
  $buildomatic_extras        = $jasperreports_server::buildomatic_extras,
) inherits jasperreports_server::params {

  include stdlib
  # Include archive class to install required faraday gems
  include ::archive

  if $pkg_version == undef {
    fail("${title}: pkg_version not set")
  }

  validate_hash($buildomatic_extras)

  # Check to see which version of Java we should install
  # Install OpenJDK 1.8 if JasperReports version is 1.6.0 or higher
  if versioncmp($pkg_version, '1.6.0') >= 0 {
    ensure_packages('java-1.8.0-openjdk', {'ensure' => 'present'})
  } else {
    ensure_packages('java-1.6.0-openjdk', {'ensure' => 'present'})
  }

  # Set the Source URL
  if ( $source_url == undef ) {
    $nsource_url = "http://kent.dl.sourceforge.net/project/jasperserver/JasperServer/JasperReports%20Server%20Community%20Edition%20${pkg_version}/jasperreports-server-cp-${pkg_version}-bin.zip"
  }
  else {
    $nsource_url = $source_url
  }

  if ( $nsource_url ) and ( $nexus_url == undef ) {
    include wget

    wget::fetch { 'Download JasperReports Server Binary':
      source      => $nsource_url,
      destination => "/tmp/jasperreports-server-cp-${pkg_version}-bin.zip",
      timeout     => 0,
      verbose     => false,
    } ->
    exec { 'Unzip JasperReports Server Binary':
      user    => $buildomatic_user,
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => "unzip -q /tmp/jasperreports-server-cp-${pkg_version}-bin.zip -d /tmp",
      onlyif  => "test ! -d /tmp/jasperreports-server-cp-${pkg_version}-bin",
      before  => File['default_master.properties'],
      unless  => "test -d ${buildomatic_appserverdir}/webapps/jasperserver",
    }
  }
  elsif ( $nexus_url != undef ) {
    archive::nexus { "/tmp/jasperreports-server-cp-${pkg_version}-bin.zip":
      ensure       => present,
      url          => $nexus_url,
      gav          => $nexus_gav,
      repository   => $nexus_repository,
      packaging    => $nexus_packaging,
      classifier   => $nexus_classifier,
      owner        => $buildomatic_user,
      user         => $buildomatic_user,
      group        => $buildomatic_user,
      extract      => true,
      extract_path => '/tmp',
      creates      => "${buildomatic_appserverdir}/webapps/jasperserver",
      require      => Class['archive'],
      before       => File['default_master.properties'],
    }
  }

  file { 'default_master.properties':
    ensure  => present,
    path    => "$buildomatic_appserverdir/jasper_default_master.properties",
    owner   => root,
    group   => root,
    mode    => '0700',
    content => template('jasperreports_server/default_master.properties.erb'),
  }

  exec { 'Symlink default_master.properties':
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "ln -s $buildomatic_appserverdir/jasper_default_master.properties /tmp/jasperreports-server-cp-${pkg_version}-bin/buildomatic/default_master.properties",
    unless  => "test -d ${buildomatic_appserverdir}/webapps/jasperserver",
    require => File['default_master.properties'],
  } ->
  # Run the js-install with minimal flag
  exec { 'Run js-install minimal':
    path    => "/bin:/usr/bin:/sbin:/usr/sbin:/tmp/jasperreports-server-cp-${pkg_version}-bin/buildomatic",
    cwd     => "/tmp/jasperreports-server-cp-${pkg_version}-bin/buildomatic",
    command => 'js-install-ce.sh minimal',
    creates => "${buildomatic_appserverdir}/webapps/jasperserver",
    user    => $buildomatic_user,
    timeout => '400',
  } ->
  # Dirty hack because of issues getting js-install to run as non-root user
  exec { 'Update Jasper WebApp Ownership':
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command     => "chown -R tomcat:tomcat ${buildomatic_appserverdir}/webapps/jasperserver",
    unless      => "stat -c %U ${buildomatic_appserverdir}/webapps/jasperserver | grep -q 'tomcat'",
    subscribe   => Exec['Run js-install minimal'],
    refreshonly => true,
  }

}
