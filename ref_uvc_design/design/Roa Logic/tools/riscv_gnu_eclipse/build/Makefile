#
# usage: make -B
#
# The -B ignores timestamps, thus forcing rebuild-all
#
# Make sure to update ALL MANIFEST.MF files and site.xml
# The versions must all match


# Eclipse workspace location.
ECLIPSE_WORKSPACE := ..

# Choose ZIP executable, because on servers default is zip ancient like
# dinosaurs and we need to override it.
ZIP_BIN := zip

# Location of Eclipse installation.
ECLIPSE_HOME := ../../eclipse

# Qualifier
VERSION_QUALIFIER := $(shell date --utc +%Y%m%d%H%M)


all: riscv_gnu_plugins.zip

%.zip: %
	cd $< && $(ZIP_BIN) -vr - * > ../$@
	cp $@ ../archive/$*_$(VERSION_QUALIFIER).zip

riscv_gnu_plugins: feature_export
	sed -e 's/qualifier/$(VERSION_QUALIFIER)/g' ../updatesite/site.xml > $</site.xml
	$(ECLIPSE_HOME)/eclipse -nosplash \
	    -data $(ECLIPSE_WORKSPACE) \
	    -application org.eclipse.equinox.p2.publisher.UpdateSitePublisher \
	    -metadataRepository file://$$(readlink -m $@) \
	    -artifactRepository file://$$(readlink -m $@) \
	    -source $<\
	    -publishArtifacts \
	    -compress

feature_export: feature_export.xml
	$(ECLIPSE_HOME)/eclipse \
	    -DVERSION_QUALIFIER=$(VERSION_QUALIFIER) \
	    -nosplash \
	    -application org.eclipse.ant.core.antRunner \
	    -f $< \
	    -data $(ECLIPSE_WORKSPACE)


.NOTPARALLEL: clean
.PHONY: clean
clean:
	rm -rf feature_export riscv_gnu_plugins *.zip

.PHONY:
help:
	@echo "Targets:"
	@echo "all      Build all"
	@echo "clean    Remove artifacts"
	@echo "feature_export"
	@echo "riscv_gnu_plugins"
	@echo "riscv_gnu_plugin.zip"
	@echo "help     Show this help"

