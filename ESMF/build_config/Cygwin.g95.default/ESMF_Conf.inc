#if 0
$Id: ESMF_Conf.inc,v 1.1.5.1 2013-01-11 20:23:43 mathomp4 Exp $

Earth System Modeling Framework
Copyright 2002-2012, University Corporation for Atmospheric Research,
Massachusetts Institute of Technology, Geophysical Fluid Dynamics
Laboratory, University of Michigan, National Centers for Environmental
Prediction, Los Alamos National Laboratory, Argonne National Laboratory,
NASA Goddard Space Flight Center.
Licensed under the University of Illinois-NCSA License.
#endif

#if 0
the GNU G95 compiler has a bug which prevents forward pointer references from
working if also using the sequence keyword.  for PGI and G95 only, do not sequence
the State derived types.
#endif

#define ESMF_SEQUENCE_BUG 0


