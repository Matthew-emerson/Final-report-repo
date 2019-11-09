qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path data \
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path demux-paired-end.qza
qiime demux summarize \
  --i-data demux-paired-end.qza \
  --o-visualization demux-paired-end.qzv
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux-paired-end.qza \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 248 \
  --p-trunc-len-r 156 \
  --o-representative-sequences rep-seqs-dada2.qza \
  --o-table table.dada2.qza \
  --o-denoising-stats stats-dada2.qza \
qiime metadata tabulate \
  --m-input-file stats-dada2.qza \
  --o-visualization stats-dada2.qzv
qiime feature-table summarize   
  --i-table table.dada2.qza
  --o-visualization table-dada2.qzv
  --m-sample-metadata-file Metadata.tsv
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-dada2.qza \
  --o-visualization rep-seqs-dada2.qzv
 qiime alignment mafft
  --i-sequences rep-seqs-dada2.qza
  --o-alignment aligned-rep-seqs.qza
  --p-parttree  
  --p-n-threads 0
qiime alignment mask \
  --i-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree
  --i-alignment masked-aligned-rep-seqs.qza
  --o-tree unrooted-tree.qza
  --p-n-threads 0
qiime phylogeny midpoint-root \
  --i-tree unrooted-tree.qza \
  --o-rooted-tree midpoint-rooted-tree.qza
qiime feature-classifier classify-sklearn \
  --i-classifier silva-132-99-515-806-nb-classifier.qza \
  --i-reads rep-seqs-dada2.qza \
  --o-classification taxonomy.qza
qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
qiime taxa barplot \
  --i-table table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file Metadata.tsv\
  --o-visualization taxa-bar-plots.qzv
qiime feature-table group \
  --i-table table-dada2.qza \
  --m-metadata-file Metadata.tsv \
  --m-metadata-column Group_diet \
  --p-axis sample \
  --p-mode mean-ceiling \
  --o-grouped-table grouped-table-dada2-groups.qza
qiime taxa barplot \
  --i-table grouped-table-dada2-groups.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file Metadata.tsv \
  --o-visualization grouped-taxa-bar-plots-groups.qzv
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny midpoint-rooted-tree.qza \
  --i-table table-dada2.qza \
  --p-sampling-depth 100893 \
  --m-metadata-file Metadata.tsv \
  --output-dir core-metrics-results \
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file Metadata.tsv \
  --o-visualization core-metrics-results/unweighted_unifrac_emperor.qzv
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file Metadata.tsv \
  --m-metadata-column Group_diet \
  --o-visualization core-metrics-results/unweighted-unifrac-Group-diet-significance.qzv \
  --p-pairwise
