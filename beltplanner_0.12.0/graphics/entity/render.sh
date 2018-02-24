#! /bin/sh

set -ex

INPUT=beltplanner.pov
RES=1
W=$((96*$RES))
H=$((72*$RES))

POVRAY="povray +A0.2 +UA +W${W} +H${H}"

${POVRAY} ${INPUT} Declare=NO_GROUND=1 +Obeltplanner-entity.png
${POVRAY} ${INPUT} +Obeltplanner-shadow.png
