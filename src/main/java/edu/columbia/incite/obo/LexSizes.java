/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.columbia.incite.obo;

import edu.columbia.incite.Lector;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.apache.lucene.index.LeafReader;
import org.apache.lucene.index.Terms;
import org.apache.lucene.index.TermsEnum;

import edu.columbia.incite.obo.corpus.OBOTokenFields;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 */
public class LexSizes {

    public static void main( String[] args ) throws IOException {
        Lector obo = new Lector();
        LeafReader ir = obo.indexReader();
        getTopTerms(ir, OBOTokenFields.FIELD_RAW_FULL );
        getTopTerms(ir, OBOTokenFields.FIELD_RAW_CONF );
        getTopTerms(ir, OBOTokenFields.FIELD_LEMMA_FULL );
        getTopTerms(ir, OBOTokenFields.FIELD_LEMMA_CONF );
    }

    static void getTopTerms( LeafReader ir, String field ) throws IOException {
        System.out.printf( "============ %s ==========\n", field );
        Terms terms = ir.terms( field );
        TermsEnum tEnum = terms.iterator();
        int  tct   = 0;
        long ttf   = 0;
        int  tct_5 = 0;
        long ttf_5 = 0;
        List<Long> tfs = new ArrayList<>();
        List<Long> tfs_5 = new ArrayList<>();
        while( ( tEnum.next() ) != null ) {
            long tf = tEnum.totalTermFreq();

            tct_5++;
            tfs_5.add( tf );
            ttf_5 += tf;

            if( tf < 5 ) continue;
            tct++;
            tfs.add( tf );
            ttf += tf;
        }
        tfs.sort( Collections.reverseOrder() );
        tfs_5.sort( Collections.reverseOrder() );

        System.out.println( "Excluding < 5:" );
        printIt( ttf, tct, tfs );
        System.out.println( "Including < 5:" );
        printIt( ttf_5, tct_5, tfs_5 );
    }

    static void printIt( long ttf, int tct, List<Long> tfs ) {
        System.out.printf( "Term count: %d\n", tct );
        System.out.printf( "Token len: %d\n", ttf );
        double cover = 0;
        boolean s50 = false;
        boolean s95 = false;
        for( int i = 0; i < tfs.size(); i++ ) {
            if( s50 && s95 ) break;
            cover += (double) tfs.get( i ) / (double) ttf;
            if( !s50 && cover >= .5  ) { System.out.printf( "S50 at %d\n", i ); s50 = true; }
            if( !s95 && cover >= .95 ) { System.out.printf( "S95 at %d\n", i ); s95 = true; }
        }
    }

}
