USE DB_NAME;

DROP TABLE IF EXISTS TABLE_NAME;

CREATE TABLE TABLE_NAME (
	seqid VARCHAR(255) NOT NULL,
	position BIGINT UNSIGNED NOT NULL,
	countA BIGINT UNSIGNED NOT NULL,
	countC BIGINT UNSIGNED NOT NULL,
	countG BIGINT UNSIGNED NOT NULL,
	countT BIGINT UNSIGNED NOT NULL,
	countN BIGINT UNSIGNED NOT NULL,
	iupac_nuc ENUM('A', 'C', 'G', 'T', 'U', 'R', 'Y', 'S', 'W', 'K', 'M', 'B', 'D', 'H', 'V', 'N', '.', '_', 'NA') NOT NULL,
	insertions VARCHAR(255),
	PRIMARY KEY (seqid, position)
) ENGINE=INNODB;

LOAD DATA LOCAL INFILE INFO_FROM_PILEUP
INTO TABLE TABLE_NAME
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(@col1, @col2, @col3, @col4, @col5, @col6, @col7, @col8, @col9) set seqid=@col1, position=@col2, countA=@col3, countC=@col4, countG=@col5, countT=@col6, countN=@col7, iupac_nuc=@col8, insertions=@col9;
