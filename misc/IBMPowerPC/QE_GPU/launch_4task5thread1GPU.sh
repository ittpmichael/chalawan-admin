#! /bin/sh

  if [ ${OMPI_COMM_WORLD_LOCAL_RANK} -eq 0 ]; then
  export CUDA_VISIBLE_DEVICES=0
  export OMP_PLACES="{0},{8},{16},{24},{32}"
  taskset -p -c 0-39 $$
elif [ ${OMPI_COMM_WORLD_LOCAL_RANK} -eq 1 ]; then
  export CUDA_VISIBLE_DEVICES=1
  export OMP_PLACES="{40},{48},{56},{64},{72}"
  taskset -p -c 40-79 $$
elif [ ${OMPI_COMM_WORLD_LOCAL_RANK} -eq 2 ]; then
  export CUDA_VISIBLE_DEVICES=2
  export OMP_PLACES="{80},{88},{96},{104},{112}"
  taskset -p -c 80-119 $$
elif [ ${OMPI_COMM_WORLD_LOCAL_RANK} -eq 3 ]; then
  export CUDA_VISIBLE_DEVICES=3
  export OMP_PLACES="{120},{128},{136},{144},{152}"
  taskset -p -c 120-159 $$
else
  echo "Error: $0 is not designed for this case."
  exit 1
fi

exec $*
