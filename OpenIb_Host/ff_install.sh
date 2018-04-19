#!/bin/bash
set -x

[ -z "${BUILDDIR}" ] && BUILDDIR="."
[ -z "${DESTDIR}" ] && DESTDIR="/"
[ -z "${LIBDIR}" ] && LIBDIR=/usr/lib

if [ ! -f "${BUILDDIR}/RELEASE_PATH" ]; then
    echo "Wrong BUILDDIR? No such file ${BUILDDIR}/RELEASE_PATH"
    exit 1
fi

source OpenIb_Host/ff_filegroups.sh

release_string="IntelOPA-Tools-FF.$BUILD_TARGET_OS_ID.$MODULEVERSION"

mkdir -p ${DESTDIR}/usr/bin
mkdir -p ${DESTDIR}/usr/sbin
mkdir -p ${DESTDIR}/usr/lib/opa/{tools,fm_tools}
mkdir -p ${DESTDIR}/usr/share/opa/{samples,help}
mkdir -p ${DESTDIR}/usr/lib/ibacm
mkdir -p ${DESTDIR}/etc/rdma
mkdir -p ${DESTDIR}/etc/opa
mkdir -p ${DESTDIR}/usr/include/infiniband
mkdir -p ${DESTDIR}/usr/include/opamgt/iba/public
mkdir -p ${DESTDIR}/usr/src/opamgt
mkdir -p ${DESTDIR}/usr/share/man/man1
mkdir -p ${DESTDIR}/usr/share/man/man8
mkdir -p ${DESTDIR}/usr/src/opa/{mpi_apps,shmem_apps}

# Copy the comp.pl file before changing directories
cp -t ${DESTDIR}/usr/lib/opa OpenIb_Host/.comp_fastfabric.pl
cp -t ${DESTDIR}/usr/lib/opa OpenIb_Host/.comp_oftools.pl

#Binaries and scripts installing (basic tools)
#cd builtbin.OPENIB_FF.release
cd $(cat ${BUILDDIR}/RELEASE_PATH)

cd bin
cp -t ${DESTDIR}/usr/sbin $basic_tools_sbin
cp -t ${DESTDIR}/usr/lib/opa/tools/ $basic_tools_opt
ln -s ./opaportinfo ${DESTDIR}/usr/sbin/opaportconfig
ln -s ./opasmaquery ${DESTDIR}/usr/sbin/opapmaquery

cd ../opasadb
cp -t ${DESTDIR}/usr/bin $opasadb_bin
cp -t ${DESTDIR}/usr/include/infiniband $opasadb_header

cd ../opamgt
cp -t ${DESTDIR}/usr/include/opamgt $opamgt_headers
cp -t ${DESTDIR}/usr/include/opamgt/iba $opamgt_iba_headers
cp -t ${DESTDIR}/usr/include/opamgt/iba/public $opamgt_iba_public_headers
cp -t ${DESTDIR}/usr/src/opamgt $opamgt_examples

cd ../bin
cp -t ${DESTDIR}/usr/lib/opa/tools/ $ff_tools_opt

cd ../fastfabric
cp -t ${DESTDIR}/usr/sbin $ff_tools_sbin
cp -t ${DESTDIR}/usr/lib/opa/tools/ $ff_tools_misc
cp -t ${DESTDIR}/usr/share/opa/help $help_doc

cd ../etc
cp -t ${DESTDIR}/usr/lib/opa/fm_tools/ $ff_tools_fm
ln -s /usr/lib/opa/fm_tools/config_check ${DESTDIR}/usr/sbin/opafmconfigcheck
ln -s /usr/lib/opa/fm_tools/config_diff ${DESTDIR}/usr/sbin/opafmconfigdiff

cd ../fastfabric/samples
cp -t ${DESTDIR}/usr/share/opa/samples $ff_iba_samples
cd ..

cd ../fastfabric/tools
cp -t ${DESTDIR}/usr/lib/opa/tools/ $ff_tools_exp
cp -t ${DESTDIR}/usr/lib/opa/tools/ $ff_libs_misc
cp -t ${DESTDIR}/usr/lib/opa/tools/ osid_wrapper
cp -t ${DESTDIR}/etc/opa allhosts chassis esm_chassis hosts ports switches opaff.xml
cd ..

cd ../man/man1
cp -t ${DESTDIR}/usr/share/man/man1 $basic_mans
cp -t ${DESTDIR}/usr/share/man/man1 $opasadb_mans
cd ../man8
cp -t ${DESTDIR}/usr/share/man/man8 $ff_mans
cd ..

cd ../src/mpi/mpi_apps
tar -xzf mpi_apps.tgz -C ${DESTDIR}/usr/src/opa/mpi_apps/
cd ../../

cd ../src/shmem/shmem_apps
tar -xzf shmem_apps.tgz -C ${DESTDIR}/usr/src/opa/shmem_apps/
cd ../../

#Config files
cd ../config
cp -t ${DESTDIR}/etc/rdma dsap.conf
cp -t ${DESTDIR}/etc/opa opamon.conf opamon.si.conf

#Libraries installing
#cd ../builtlibs.OPENIB_FF.release
cd $(cat $BUILDDIR/LIB_PATH)
cp -t ${DESTDIR}/usr/lib libopasadb.so.*
cp -t ${DESTDIR}/usr/lib/ibacm libdsap.so.*
cp -t ${DESTDIR}/usr/lib libopamgt.so.*
ln -s libopamgt.so.* ${DESTDIR}/usr/lib/libopamgt.so.0
ln -s libopamgt.so.0 ${DESTDIR}/usr/lib/libopamgt.so


# Now that we've put everything in the buildroot, copy any default config files to their expected location for user
# to edit. To prevent nuking existing user configs, the files section of this spec file will reference these as noreplace
# config files.
cp ${DESTDIR}/usr/lib/opa/tools/opafastfabric.conf.def ${DESTDIR}/etc/opa/opafastfabric.conf

