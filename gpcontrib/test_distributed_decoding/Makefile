# contrib/test_distributed_decoding/Makefile

MODULES = test_distributed_decoding
PGFILEDESC = "test_distributed_decoding - It is almost identical to logical decoding, but adds tests for decoding distributed_forget log and decoding one-phase transactions log."

REGRESS = distributed_transaction one_phase

REGRESS_OPTS = --temp-config $(top_srcdir)/contrib/test_distributed_decoding/logical.conf

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/test_distributed_decoding
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

# But it can nonetheless be very helpful to run tests on preexisting
# installation, allow to do so, but only if requested explicitly.
installcheck-force:
	$(pg_regress_installcheck) $(REGRESS)
