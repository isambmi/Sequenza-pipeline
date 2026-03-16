#!/bin/bash

set -eu

#
# parse args
#
usage() {
  cat << EOS
Usage: `basename $0` [options]
  -s SAMPLE_ID    Sample ID (required)
  -t TUMOR_BAM    Tumor BAM file (required)
  -n NORMAL_BAM   Normal BAM file (required)
  -r REF_FASTA    FASTA file of GRCh37 (required)
  -c THREADS      The number of threads (optional; default 1)
  -h              Display help message
EOS
  exit 1
}

num_threads=1
while getopts s:t:n:r:c:h OPT; do
  case $OPT in
    s ) sample_id=$OPTARG;;
    t ) tumor_bam=$OPTARG;;
    n ) normal_bam=$OPTARG;;
    r ) reference_fasta=$OPTARG;;
    c ) num_threads=$OPTARG;;
    h ) usage;;
    ? ) usage;;
  esac
done

echo "Identifying chr prefix with samtools ..."
#
# identify chromosome prefix from header
#
if /opt/conda/bin/samtools view -H "$tumor_bam" | grep -Fq $'SN:chr1\t'; then
  chromosomes="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY"
  chr_prefix="chr"
else
  chromosomes="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y"
  chr_prefix=""
fi
echo "chromosomes identified"
echo $chromosomes 

echo "Computing GC contents ..."
#
# compute GC contents
#
reference_base=`basename $reference_fasta | sed -e 's/\.fa$\|\.fas$\|\.fasta$//'`
gc_wiggle="${reference_base}.gc50Base.wig.gz"
/opt/conda/bin/sequenza-utils gc_wiggle -w 50 --fasta $reference_fasta -o $gc_wiggle

#
# run Sequenza
#

echo "Generating seqz ..."
/opt/conda/bin/sequenza-utils bam2seqz \
  -n "$normal_bam" \
  -t "$tumor_bam" \
  --fasta "$reference_fasta" \
  -gc "$gc_wiggle" \
  -o "${sample_id}.seqz.gz" \
  -C ${chromosomes} \
  -T /opt/conda/bin/tabix \
  -S /opt/conda/bin/samtools \
  --parallel "$num_threads"

{
  first_chr="${chr_prefix}1"
  for chr in $chromosomes; do
    if [ "$chr" == "$first_chr" ]; then
      zcat "${sample_id}_${chr}.seqz.gz"
    else
      zcat "${sample_id}_${chr}.seqz.gz" | tail -n +2
    fi  
  done
} | /opt/conda/bin/sequenza-utils seqz_binning --seqz - -w 50 -o "${sample_id}.small.seqz.gz" -T /opt/conda/bin/tabix

echo "Run Sequenza ..."
/opt/conda/bin/Rscript /opt/sequenza-command.R ${sample_id} ${sample_id}.small.seqz.gz
rm ${sample_id}.small.seqz.gz