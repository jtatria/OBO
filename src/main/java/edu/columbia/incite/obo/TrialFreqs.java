/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.columbia.incite.obo;

import edu.columbia.incite.Lector;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.lucene.index.LeafReader;
import org.apache.lucene.index.PostingsEnum;
import org.apache.lucene.index.Terms;
import org.apache.lucene.index.TermsEnum;
import org.apache.lucene.util.BytesRef;

import edu.columbia.incite.obo.corpus.POBDocFields;
import edu.columbia.incite.obo.corpus.POBTokenFields;
import edu.columbia.incite.obo.corpus.Samples;
import edu.columbia.incite.corpus.DocSet;
import edu.columbia.incite.util.DSVWriter;
import edu.columbia.incite.util.FileUtils;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 */
public class TrialFreqs {

    public static final String TRIAL_IDS = POBDocFields.OBO_SECTION_FIELD;
    public static final String FILE = "/home/jta/desktop/obo/data/trial_freqs.dsv";
    
    
    public static void main( String[] args ) throws IOException {
        Lector obo = new Lector();
        LeafReader lr = obo.indexReader();
        
        Map<String,Map<String,Long>> data = new HashMap<>();
        
        getColumn( data, POBTokenFields.FIELD_RAW_FULL,   lr );
        getColumn( data, POBTokenFields.FIELD_RAW_CONF,   lr );
        getColumn( data, POBTokenFields.FIELD_LEMMA_FULL, lr );
        getColumn( data, POBTokenFields.FIELD_LEMMA_CONF, lr );
        
        DSVWriter.write( FileUtils.getWriter( Paths.get( FILE ) ), data );
    }
    
    public static void getColumn( Map<String,Map<String,Long>> data, String field, LeafReader lr )
    throws IOException {
        System.out.println( field );
        Map<String,Long> rawFull = trialTerms( lr, field );
        for( Entry<String,Long> e : rawFull.entrySet() ) {
            data.computeIfAbsent( e.getKey(), ( k ) -> new HashMap<>()  );
            data.get( e.getKey() ).put( field, e.getValue() );
        }
    }
    
    public static Map<String,Long> trialTerms( LeafReader lr, String field ) throws IOException {        
        Map<String,Long> data = new HashMap<>();
        TermsEnum divs = lr.terms( TRIAL_IDS ).iterator();
        BytesRef t = null;
        PostingsEnum pEnum = null;
        DocSet sample = Samples.getSample( lr, Samples.TRIALS );
        while( ( t = divs.next() ) != null ) {
            long trialTf = 0;
            pEnum = sample.filter( divs.postings( pEnum, PostingsEnum.ALL ) );
            int para;
            while( ( para = pEnum.nextDoc() ) != PostingsEnum.NO_MORE_DOCS ) {
                Terms tv = lr.getTermVector( para, field );
                if( tv != null ) {
                    TermsEnum tEnum = tv.iterator();
                    while( tEnum.next() != null ) {
                        trialTf += tEnum.docFreq();
                    }
                }
            }
            data.put( t.utf8ToString(), trialTf );
        }        
        return data;
    }
    
}
