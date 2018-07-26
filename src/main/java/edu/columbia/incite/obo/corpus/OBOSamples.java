/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo.corpus;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.AutomatonQuery;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.MatchAllDocsQuery;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.util.automaton.Automata;

import edu.columbia.incite.corpus.DocSet;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 */
public class OBOSamples {
    public static final String UNIVERSE_KEY = "UNIVERSE";
    public static final Query UNIVERSE = new MatchAllDocsQuery();
    
    public static final String LEGAL_KEY = "LEGAL";
    public static final Query LEGAL = new AutomatonQuery(
        new Term( OBOTokenFields.FIELD_LEGAL, "" ), Automata.makeAnyString()
    );
    
    public static final String TRIALS_KEY = "TRIALS";
    public static final Query TRIALS = new TermQuery(
        new Term( OBODocFields.OBO_TYPE_FIELD, "trialAccount" )
    );
    
    public static final String TESTIMONY_KEY = "TESTIMONY";
    public static final Query TESTIMONY;
    static {
        BooleanQuery.Builder bldr = new BooleanQuery.Builder();
        bldr.add( TRIALS, BooleanClause.Occur.MUST );
        bldr.add( LEGAL, BooleanClause.Occur.MUST_NOT );
        TESTIMONY = bldr.build();
    }
    
    public static final Map<String,Query> SAMPLES;
    static {
        Map<String,Query> tmp = new HashMap<>();
        tmp.put( LEGAL_KEY, LEGAL );
        tmp.put( TRIALS_KEY, TRIALS );
        tmp.put( TESTIMONY_KEY, TESTIMONY );
        SAMPLES = Collections.unmodifiableMap( tmp );
    }
    
    public static DocSet getSample( IndexReader ir, String key ) throws IOException {
        String KEY = key.toUpperCase( Locale.ROOT );
        if( !SAMPLES.containsKey( KEY ) ) {
            throw new IllegalArgumentException(
                String.format( "Unknown sample requested: %s", key ) 
            );
        }
        return getSample( ir, SAMPLES.get( KEY ) );
    }

    public static DocSet complement( IndexReader ir, String key ) throws IOException {
        String KEY = key.toUpperCase( Locale.ROOT );
        if( !SAMPLES.containsKey( KEY ) ) {
            throw new IllegalArgumentException( 
                String.format( "Unknown sample requested: %s", key ) 
            );
        }
        return complement( ir, SAMPLES.get( KEY ) );
    }
    
    public static DocSet getSample( IndexReader ir, Query q ) throws IOException {
        IndexSearcher is = new IndexSearcher( ir );
        TopDocs hits = is.search( q, ir.numDocs() );
        return new DocSet( hits, ir.numDocs() );
    }   
    
    public static DocSet complement( IndexReader ir, Query q ) throws IOException {
        BooleanQuery.Builder bldr = new BooleanQuery.Builder();
        bldr.add( UNIVERSE, BooleanClause.Occur.FILTER );
        bldr.add( q, BooleanClause.Occur.MUST_NOT );
        Query notq = bldr.build();
        IndexSearcher is = new IndexSearcher( ir );
        TopDocs hits = is.search( notq, ir.numDocs() );
        return new DocSet( hits, ir.numDocs() );
    }
}
