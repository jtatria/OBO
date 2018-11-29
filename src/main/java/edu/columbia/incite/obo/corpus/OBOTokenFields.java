/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo.corpus;

import java.util.HashMap;
import java.util.Map;

import de.tudarmstadt.ukp.dkpro.core.api.segmentation.type.Token;
import org.apache.lucene.document.FieldType;
import org.apache.lucene.index.IndexOptions;
import org.apache.uima.fit.component.Resource_ImplBase;
import org.apache.uima.fit.descriptor.ConfigurationParameter;
import org.apache.uima.resource.ResourceInitializationException;
import org.apache.uima.resource.ResourceSpecifier;

import edu.columbia.incite.uima.index.CorpusIndexer.TokenSpec;
import edu.columbia.incite.uima.index.DKProTokenizer;
import edu.columbia.incite.uima.index.InciteTokenizer;
import edu.columbia.incite.corpus.POSClass;
import edu.columbia.incite.corpus.TermSet;
import edu.columbia.incite.uima.SimpleResource;
import edu.columbia.incite.uima.api.types.obo.Legal;

import static edu.columbia.incite.obo.corpus.OBOTermSets.*;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 */
public class OBOTokenFields extends Resource_ImplBase 
    implements SimpleResource<Map<String,TokenSpec>> {
    
    public static final String PARAM_ADD_RAW_FULL = "addRawFull";
    @ConfigurationParameter( name = PARAM_ADD_RAW_FULL, mandatory = false, defaultValue = "true" )
    private Boolean addRawFull;
    
    public static final String PARAM_ADD_LEMMA_FULL = "addLemmaFull";
    @ConfigurationParameter( name = PARAM_ADD_LEMMA_FULL, mandatory = false, defaultValue = "true" )
    private Boolean addLemmaFull;
    
    public static final String PARAM_ADD_RAW_CONF = "addRawConflated";
    @ConfigurationParameter( name = PARAM_ADD_RAW_CONF, mandatory = false, defaultValue = "true" )
    private Boolean addRawConflated;
    
    public static final String PARAM_ADD_LEMMA_CONF = "addLemmaConflated";
    @ConfigurationParameter( name = PARAM_ADD_LEMMA_CONF, mandatory = false, defaultValue = "true" )
    private Boolean addLemmaConflated;
    
    public static final String PARAM_LEGAL = "addLegal";
    @ConfigurationParameter( name = PARAM_LEGAL, mandatory = false, defaultValue = "true" )
    private Boolean addLegal;
    
    /**
     * Field name for raw text, no conflation.
     */
    public static final String FIELD_RAW_FULL   = "full_text";
    
    /**
     * Field name for lemmatized text, no conflation.
     */
    public static final String FIELD_LEMMA_FULL = "full_lemma";
    
    /**
     * Field name for raw text, conflated.
     */
    public static final String FIELD_RAW_CONF   = "wrk_text";
    
    /**
     * Field name for lemmatized text, conflated.
     */
    public static final String FIELD_LEMMA_CONF = "wrk_lemma";
    
    /**
     * Field type for legal entities.
     */
    public static final String FIELD_LEGAL      = "ent_legal";
    
    /**
     * Excluded POS classes.
     */
    public static final POSClass[] EXCLUDED_POS = new POSClass[]{ POSClass.PUNC };
    
    /**
     * Global term deletions. Stop words would normally go here.
     */
    public static final TermSet[] TERM_DELETIONS = new TermSet[]{
        L_PUNCT
    };
    
    /**
     * Term set for un-conflated fields. I.e. the empty set.
     */
    public static final TermSet[] SUBTS_FULL = new TermSet[]{
        TermSet.EMPTY
    };
        
    /**
     * Term set for conflated fields: Ordinals, Money, Weight, Length, Cardinals.
     */
    public static final TermSet[] SUBSTS_CONF = new TermSet[]{
        L_ORD, L_MONEY, L_WEIGHT, L_LENGTH, L_NUMBER,
    };
    
    /**
     * UIMA type name for token annotations
     */
    public static final String ANNTYPE_TOKENS = Token.class.getName();
    
    /**
     * UIMA type name for legal annotations
     */
    public static final String ANNTYPE_LEGAL  = Legal.class.getName();
    
    /**
     * Lucene field type for term vector field, i.e. all text fields, since we need term vectors for 
     * co-occurrence counts.
     */
    public static final FieldType FIELD_TYPE_WITHTV = new FieldType();
    
    /**
     * Lucene type for doc-only fields, i.e. legal entities, since they are used only a provenance 
     * data.
     */
    public static final FieldType FIELD_TYPE_DOCS   = new FieldType();
    static {
        FIELD_TYPE_WITHTV.setIndexOptions( IndexOptions.DOCS_AND_FREQS_AND_POSITIONS_AND_OFFSETS );
        FIELD_TYPE_WITHTV.setStoreTermVectors( true );
        FIELD_TYPE_WITHTV.setStoreTermVectorPositions( true );
        FIELD_TYPE_WITHTV.setStoreTermVectorPayloads( true );
        FIELD_TYPE_WITHTV.setStoreTermVectorOffsets( true );
        FIELD_TYPE_WITHTV.setTokenized( true );
        
        FIELD_TYPE_DOCS.setIndexOptions( IndexOptions.DOCS );
    }

    private final Map<String,TokenSpec> STREAMS = new HashMap<>();
    
    @Override
    public boolean initialize( ResourceSpecifier rs, Map<String,Object> paras )
    throws ResourceInitializationException {
        boolean ret = super.initialize( rs, paras );    
        
        if( addRawFull ) {
            STREAMS.put(FIELD_RAW_FULL,  new TokenSpec( ANNTYPE_TOKENS, FIELD_TYPE_WITHTV,
                new POBTokenizer( false, TERM_DELETIONS, SUBTS_FULL )
            ) );
        }

        if( addLemmaFull ) {
            STREAMS.put(FIELD_LEMMA_FULL, new TokenSpec( ANNTYPE_TOKENS, FIELD_TYPE_WITHTV, 
                new POBTokenizer( true, TERM_DELETIONS, SUBTS_FULL )
            ) );
        }

        if( addRawConflated ) {
            STREAMS.put(FIELD_RAW_CONF,   new TokenSpec( ANNTYPE_TOKENS, FIELD_TYPE_WITHTV, 
                new POBTokenizer( false, TERM_DELETIONS, SUBSTS_CONF )
            ) );
        }

        if( addLemmaConflated ) {
            STREAMS.put(FIELD_LEMMA_CONF,  new TokenSpec( ANNTYPE_TOKENS, FIELD_TYPE_WITHTV, 
                new POBTokenizer( true, TERM_DELETIONS, SUBSTS_CONF )
            ) );
        }

        if( addLegal ) {
            STREAMS.put(FIELD_LEGAL,      new TokenSpec( ANNTYPE_LEGAL, FIELD_TYPE_DOCS,
                new InciteTokenizer() ) 
            );
        }

        return ret;
    }
    
    @Override
    public Map<String,TokenSpec> get() {
        return STREAMS;
    }
    
    private static class POBTokenizer extends DKProTokenizer {
        
        private final TermSet delete;
        private final TermSet subst;
        private final TermSet[] substs;
        
        public POBTokenizer( boolean lemmatize, TermSet[] delete, TermSet[] substs ) {
            super( EXCLUDED_POS, false, lemmatize );
            this.delete = TermSet.union( null, delete );
            this.subst  = TermSet.union( null, substs );
            this.substs = substs;
        }
    
        @Override
        public String posFilter( String term ) {
            if( delete.test( term ) ) return NOTERM;
            if( subst.test( term ) ) {
                for( TermSet ts : substs ) {
                    term = ts.apply( term );
                }
            }
            return term;
        }
    }
}
