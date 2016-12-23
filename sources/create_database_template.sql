DROP DATABASE IF EXISTS DB_NAME;

CREATE DATABASE DB_NAME CHARACTER SET 'utf8';

USE DB_NAME;

CREATE TABLE Reference_positions (
	seqid VARCHAR(255) NOT NULL,
	position BIGINT UNSIGNED NOT NULL,
	nucleotide_plus ENUM('A', 'C', 'G', 'T', 'U', 'R', 'Y', 'S', 'W', 'K', 'M', 'B', 'D', 'H', 'V', 'N', '.', '-') NOT NULL,
	codon_plus SET('A', 'C', 'G', 'T', 'U', 'R', 'Y', 'S', 'W', 'K', 'M', 'B', 'D', 'H', 'V', 'N', '.', '-'),
	acideamine_plus ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z'),
	nucleotide_minus ENUM('A', 'C', 'G', 'T', 'U', 'R', 'Y', 'S', 'W', 'K', 'M', 'B', 'D', 'H', 'V', 'N', '.', '-'),
	codon_minus SET('A', 'C', 'G', 'T', 'U', 'R', 'Y', 'S', 'W', 'K', 'M', 'B', 'D', 'H', 'V', 'N', '.', '-'),
	acideamine_minus ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z'),
	PRIMARY KEY (seqid)
) ENGINE=INNODB;

CREATE TABLE Reference_features (
	seqid VARCHAR(255),
	strand ENUM('+', '-'),
	start_position BIGINT,
	end_position BIGINT,
	type VARCHAR(255),
	feature_id VARCHAR(255),
	PRIMARY KEY (feature_id)
) ENGINE=INNODB;
