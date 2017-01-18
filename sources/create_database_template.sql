DROP DATABASE IF EXISTS DB_NAME;

CREATE DATABASE DB_NAME CHARACTER SET 'utf8';

USE DB_NAME;

CREATE TABLE Reference_positions (
	seqid VARCHAR(255) NOT NULL,
	position BIGINT UNSIGNED NOT NULL,

	nucleotide_plus ENUM('A', 'C', 'G', 'T', 'U', 'R', 'Y', 'S', 'W', 'K', 'M', 'B', 'D', 'H', 'V', 'N', '.', '_', 'NA') NOT NULL,

	codon_plus ENUM('AAA', 'AAC', 'AAG', 'AAT', 'ACA', 'ACC', 'ACG', 'ACT', 'AGA', 'AGC', 'AGG', 'AGT', 'ATA', 'ATC', 'ATG', 'ATT', 'CAA', 'CAC', 'CAG', 'CAT', 'CCA', 'CCC', 'CCG', 'CCT', 'CGA', 'CGC', 'CGG', 'CGT', 'CTA', 'CTC', 'CTG', 'CTT', 'GAA', 'GAC', 'GAG', 'GAT', 'GCA', 'GCC', 'GCG', 'GCT', 'GGA', 'GGC', 'GGG', 'GGT', 'GTA', 'GTC', 'GTG', 'GTT', 'TAA', 'TAC', 'TAG', 'TAT', 'TCA', 'TCC', 'TCG', 'TCT', 'TGA', 'TGC', 'TGG', 'TGT', 'TTC', 'TTT', 'TTA', 'TTG', '.', '_', 'NA') NOT NULL,

	amino_acid_plus ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z', '_', 'NA') NOT NULL,

	nucleotide_minus ENUM('A', 'C', 'G', 'T', 'U', 'R', 'Y', 'S', 'W', 'K', 'M', 'B', 'D', 'H', 'V', 'N', '.', '_', 'NA') NOT NULL,

	codon_minus ENUM('AAA', 'AAC', 'AAG', 'AAT', 'ACA', 'ACC', 'ACG', 'ACT', 'AGA', 'AGC', 'AGG', 'AGT', 'ATA', 'ATC', 'ATG', 'ATT', 'CAA', 'CAC', 'CAG', 'CAT', 'CCA', 'CCC', 'CCG', 'CCT', 'CGA', 'CGC', 'CGG', 'CGT', 'CTA', 'CTC', 'CTG', 'CTT', 'GAA', 'GAC', 'GAG', 'GAT', 'GCA', 'GCC', 'GCG', 'GCT', 'GGA', 'GGC', 'GGG', 'GGT', 'GTA', 'GTC', 'GTG', 'GTT', 'TAA', 'TAC', 'TAG', 'TAT', 'TCA', 'TCC', 'TCG', 'TCT', 'TGA', 'TGC', 'TGG', 'TGT', 'TTC', 'TTT', 'TTA', 'TTG', '.', '_', 'NA') NOT NULL,

	amino_acid_minus ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z', '_', 'NA') NOT NULL,

	PRIMARY KEY (seqid, position)
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
