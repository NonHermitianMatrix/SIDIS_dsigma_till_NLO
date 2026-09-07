
# For python linking (require f2py part of numpy)
ifeq ($(origin MENUM),undefined)
  MENUM=2
endif
P1_ag_guux/matrix$(MENUM)py.so:
	cd P1_ag_guux;make matrix$(MENUM)py.so
all:  P1_ag_guux/matrix$(MENUM)py.so 
	echo 'done'