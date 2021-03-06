#!/bin/bash -eu

dirScripts="scripts-pipeline/fsindwi"
source "$dirScripts"/util.sh
inputvars="\
    fsindwi_dwi \
    fsindwi_dwimask \
    fsindwi_fssubjectdir"
setupdo $@

outputdir=$(mktemp -d)/$case.fsindwi_output

if [ -n "${fsindwi_t2-}" ]; then  # use t2 in registration
    inputvarsExtra="fsindwi_t2 fsindwi_t1mask fsindwi_t1"
    for var in $inputvarsExtra; do
        [ -n "${!var-}" ] || { log_error "'${var}' needs to be set in SetUpData.sh"; exit 1; }
    done
    echo "Dependencies (extra T2 dependencies):"
    printvars $inputvarsExtra
    redo-ifchange $(varvalues $inputvarsExtra)
    run "$dirScripts"/fs2dwi_T2.sh --fsdir $fsindwi_fssubjectdir \
                                   --dwi $fsindwi_dwi \
                                   --dwimask $fsindwi_dwimask \
                                   --t2 $fsindwi_t2 \
                                   --t1 $fsindwi_t1 \
                                   --t1mask $fsindwi_t1mask \
                                   -o $outputdir
    run "mv $outputdir/wmparc-in-bse.nrrd $3"
else  # register t1 directly to dwi
    run "$dirScripts"/fs2dwi.sh $fsindwi_dwi $fsindwi_dwimask $fsindwi_fssubjectdir $outputdir
    run "mv $outputdir/wmparc-in-bse-1mm.nrrd $3"
fi

mv "$outputdir/log" "$1.log"
log_success "Made '$1'"
