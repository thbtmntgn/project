-- Request to retrieve the genomic sequence of a given feature id in a given indivudal
-- Here for example, the 'malmito_rna_1' feature id is used
SELECT GROUP_CONCAT( iupac_nuc SEPARATOR '') AS 'Sequence'
FROM individual1
WHERE seqid = (SELECT seqid FROM Reference_features WHERE feature_id='malmito_rna_1')
AND position >= (SELECT start_position FROM Reference_features WHERE feature_id='malmito_rna_1')
AND position <= (SELECT end_position FROM Reference_features WHERE feature_id='malmito_rna_1')
GROUP BY NULL;

-- Request to retrieve start and end position of all exon(s) of the given feature id
SELECT start_position, end_position, feature_id
FROM Reference_features
WHERE feature_id
LIKE '%malmito_rna_1-%' ;
-- add '%' character before and after to retrived exons like 'exon_malmito_rna_1-E1'
-- add the '-' caracter after feature id and before '%' character, if not exons from 'malmito_rna_10' can be retrived too
