USE DB_NAME;

LOAD DATA LOCAL INFILE INFO_FROM_FASTA
INTO TABLE Reference_positions
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(@col1, @col2, @col3, @col4, @col5, @col6, @col7, @col8) set seqid=@col1, position=@col2, nucleotide_plus=@col3, codon_plus=@col4, amino_acid_plus=@col5, nucleotide_minus=@col6, codon_minus=@col7, amino_acid_minus=@col8;

LOAD DATA LOCAL INFILE INFO_FROM_GFF
INTO TABLE Reference_features
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(@col1, @col2, @col3, @col4, @col5, @col6) set seqid=@col1, strand=@col2, start_position=@col3, end_position=@col4, type=@col5, feature_id=@col6;
