USE DB_NAME;

LOAD DATA LOCAL INFILE INFO_FROM_FASTA
INTO TABLE TABLE_NAME
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(@col1, @col2, @col3, @col4, @col5, @col6, @col7, @col8) set seqid=@col1, position=@col2, countA=@col3, countC=@col4, countG=@col5, countT=@col6, countN=@col7, iupac_nuc=@col8;
