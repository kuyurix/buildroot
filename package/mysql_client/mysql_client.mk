################################################################################
#
# mysql_client
#
################################################################################

MYSQL_CLIENT_VERSION_MAJOR = 5.1
MYSQL_CLIENT_VERSION = $(MYSQL_CLIENT_VERSION_MAJOR).70
MYSQL_CLIENT_SOURCE = mysql-$(MYSQL_CLIENT_VERSION).tar.gz
MYSQL_CLIENT_SITE = http://downloads.skysql.com/archives/mysql-$(MYSQL_CLIENT_VERSION_MAJOR)
MYSQL_CLIENT_INSTALL_STAGING = YES
MYSQL_CLIENT_DEPENDENCIES = readline ncurses
MYSQL_CLIENT_AUTORECONF = YES
MYSQL_CLIENT_LICENSE = GPLv2
MYSQL_CLIENT_LICENSE_FILES = README COPYING


ifeq ($(BR2_PACKAGE_MYSQL_CLIENT_SERVER),y)
MYSQL_CLIENT_DEPENDENCIES += host-mysql_client
HOST_MYSQL_CLIENT_DEPENDENCIES =
HOST_MYSQL_CLIENT_AUTORECONF = YES
	
HOST_MYSQL_CLIENT_CONF_OPT = \
	--with-embedded-server
endif

MYSQL_CLIENT_CONF_ENV = \
	ac_cv_sys_restartable_syscalls=yes \
	ac_cv_path_PS=/bin/ps \
	ac_cv_FIND_PROC="/bin/ps p \$\$PID | grep -v grep | grep mysqld > /dev/null" \
	ac_cv_have_decl_HAVE_IB_ATOMIC_PTHREAD_T_GCC=yes \
	ac_cv_have_decl_HAVE_IB_ATOMIC_PTHREAD_T_SOLARIS=no \
	ac_cv_have_decl_HAVE_IB_GCC_ATOMIC_BUILTINS=yes \
	mysql_cv_new_rl_interface=yes

MYSQL_CLIENT_CONF_OPT = \
	--without-ndb-binlog \
	--without-docs \
	--without-man \
	--without-libedit \
	--without-readline \
	--without-libedit \
	--disable-dependency-tracking \
	--with-low-memory \
	--with-atomic-ops=up \
	--enable-thread-safe-client \
	--without-query-cache \
	--without-plugin-partition \
	--without-plugin-daemon_example \
	--without-plugin-ftexample \
	--without-plugin-archive \
	--without-plugin-blackhole \
	--without-plugin-example \
	--without-plugin-federated \
	--without-plugin-ibmdb2i \
	--without-plugin-innobase \
	--without-plugin-innodb_plugin \
	--without-plugin-ndbcluster \
	$(ENABLE_DEBUG)

ifeq ($(BR2_PACKAGE_MYSQL_CLIENT_SERVER),y)
	MYSQL_CLIENT_CONF_OPT += --with-embedded-server

define MYSQL_CLIENT_FIX_SERVER
	support/scripts/apply-patches.sh $(@D) package/mysql_client/mysql_server mysql_client-crosscompiling.patch
endef

MYSQL_CLIENT_POST_PATCH_HOOKS += MYSQL_CLIENT_FIX_SERVER

define HOST_MYSQL_CLIENT_BUILD_CMDS
	$(MAKE) -C $(@D)
endef

define HOST_MYSQL_CLIENT_INSTALL_CMDS
	cp $(@D)/sql/gen_lex_hash $(@D)/../mysql_client-$(MYSQL_CLIENT_VERSION)/sql/mysql-gen_lex_hash
endef 

else
MYSQL_CLIENT_CONF_OPT += --without-server
endif

define MYSQL_CLIENT_REMOVE_TEST_PROGS
	rm -rf $(TARGET_DIR)/usr/mysql-test $(TARGET_DIR)/usr/sql-bench
endef

define MYSQL_CLIENT_ADD_MYSQL_LIB_PATH
	echo "/usr/lib/mysql" >> $(TARGET_DIR)/etc/ld.so.conf
endef

MYSQL_CLIENT_POST_INSTALL_TARGET_HOOKS += MYSQL_CLIENT_REMOVE_TEST_PROGS
MYSQL_CLIENT_POST_INSTALL_TARGET_HOOKS += MYSQL_CLIENT_ADD_MYSQL_LIB_PATH

$(eval $(autotools-package))
$(eval $(host-autotools-package))
