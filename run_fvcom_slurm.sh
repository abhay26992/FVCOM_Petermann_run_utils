#!/bin/bash
#
#SBATCH --account=xxxxxx
#SBATCH --job-name=PF_Qsg
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=128
#SBATCH --time=00-20:00:00
#SBATCH --mail-type=ALL
#   ______________________________________________________________
#  |                                                              | 
#  |                                                              |
#  |  Setting up and running your job on Betzy                    |
#  |  ========================================                    |
#  |                                                              |
#  |  We are now ready to begin running commands.                 |
#  |                                                              |
#  |  This job script is run as a regular shell script on the     |
#  |  first node assigned to this job, hereafter called Mother    |
#  |  Superior.                                                   |
#  |______________________________________________________________|
#
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

echo "*************************"
echo "running experiment $EXP with $INFILE"
echo ""
echo "Goto to the directory where the job was submitted from"  
cd $SLURM_SUBMIT_DIR

#
#    Don't confuse this with the below mentioned work directory.
#    This isn't really necessary here, but can be convenient if you want
#    to copy many input files to the /local/work area on the compute nodes.
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#

RUN=`pwd | awk 'BEGIN{FS="/"}{print $NF}'`
echo ""
echo "This run is called $RUN"
cd ..
EXP=`pwd | awk 'BEGIN{FS="/"}{print $NF}'`
echo ""
echo "This experiment is called EXP"
cd $RUN

echo ""
echo "cleanup old submission-log files"
#rm run_fvcom.sh.*

# define directory where the output files (log-file) shall be written
# Careful! Files are not safe on cluster/work directories
# ----------------------------------------------------------------------

RESULTDIR=/cluster/work/users/$USER/FVCOM_results
JOBDIR=$RESULTDIR/$EXP.$RUN

echo ""
echo "set redlight in result directory to avoid starting that same job twice"
mkdir $JOBDIR/redlight.$SLURM_JOBID
# mkdir $JOBDIR/output

echo ""
echo "make working directory"
# workdir=/global/work/$USER/$SLURM_JOBID.$EXP.$RUN
workdir=/cluster/work/users/$USER/$SLURM_JOBID.$EXP.$RUN
# hes
# ln-s $indir $workdir/input
mkdir -p $workdir

echo ""
echo "copy files to working directory"

executable=$SLURM_SUBMIT_DIR/../build/bin/fvcom.bin # copy executable
cp $executable $workdir

infile=$SLURM_SUBMIT_DIR/${RUN}_run.nml # copy infile
cp $infile $workdir


#fabmfile=$SLURM_SUBMIT_DIR/fabm.yaml #copy fabmfile
#cp $fabmfile $workdir

#fabmfile=$SLURM_SUBMIT_DIR/fabm_input.nml #copy fabmfile
#cp $fabmfile $workdir

indir=$SLURM_SUBMIT_DIR/input # copy input directory
#cp -r $indir $workdir
ln -s $indir $workdir/input
# pbsdsh -u cp $executable $workdir
#
#    Copy the executable to every node. After this every compute node has 
#    its own copy of the executable, in this case mpi_test.x
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#    Insert your job commands here, for instance:

echo ""
echo "goto working directory"
cd $workdir 
#module load iimpi/2020a
#module load netCDF/4.7.4-iimpi-2020a
#module load netCDF-Fortran/4.5.2-iimpi-2020a
#module load iimpi/2019a
#module load netCDF/4.6.2-iimpi-2019a
#module load netCDF-Fortran/4.4.5-iimpi-2019a
#module load GCCcore/8.2.0
echo ""
echo "RUN FVCOM"

# excecution command with flags from Ole Anders, some may be unecessairy
# **********************************************************************

#mpirun ./fvcom.bin --dbg=7 --casename=$RUN > $JOBDIR/log.$EXP.$RUN.$SLURM_JOBID
mpirun ./fvcom.bin --casename=$RUN > $JOBDIR/log.$EXP.$RUN.$SLURM_JOBID
#mpirun -n $NODENUM fvcom $RUN > $JOBDIR/log.$EXP.$RUN.$PBS_JOBID
#mpirun -n $NODENUM --mca btl self,sm,tcp fvcom $RUN > $JOBDIR/log.$EXP.$RUN.$PBS_JOBID


# **********************************************************************
#
#    Running your MPI job by launching it with "mpirun". This works for
#    when using OpenMPI. If you are using some other MPI distribution you may
#    have to use a different launcher.
#
#    Don't put the job commands in the background, e.g. by adding & at
#    the end.  Doing so will make the job escape the queuing system, 
#    create havoc with the scheduling and result in you getting angry
#    email from the sysadmins.
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#    After the job has finished it's time to clean up.
#    But be careful, if you are in the wrong catalogue you might shoot
#    yourself in the foot. Be sure to copy any important result to
#    your home catalogue before doing this. For instance:
#
# echo ""
# echo "Copy results to $JOBDIR"
# cp log.$INFILE.$PBS_JOBID $JOBDIR
#
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#    Then remember to cd out of the catalogue before you remove it
#
# pbsdsh -u rm -rf $jobdir
#
#    NEVER use "rm -rf *" !!!
#
#    If you for some reason is in the wrong place, say, in your home
#    catalogue, you will lose data. 90% of all restores we do from backup
#    is because of people having this in their job scripts.

echo ""
echo "remove working directory"
cd /tmp

# rm -rf $workdir
rm -rf $JOBDIR/redlight.$SLURM_JOBID

echo "************************"
echo "Job done!!!"

#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#    The job ends when the script exit.
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

