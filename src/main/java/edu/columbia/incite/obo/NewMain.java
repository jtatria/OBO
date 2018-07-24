/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.columbia.incite.obo;

import java.io.IOException;

import org.apache.lucene.index.Term;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopDocs;

import edu.columbia.incite.Conf;
import edu.columbia.incite.Lector;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 */
public class NewMain {

    /**
     * @param args the command line arguments
     */
    public static void main( String[] args ) throws IOException {
        Conf conf = new Conf();
        conf.set( Conf.PARAM_HOME_DIR, "/home/jta/desktop/obo" );
        Lector obo = new Lector( conf );
        IndexSearcher is = new IndexSearcher( obo.indexReader() );
        
        Query q = new TermQuery( new Term( "obo_section", "t18940305-268" ) );
        TopDocs hits = is.search( q, 1000 );
        for( ScoreDoc sd : hits.scoreDocs ) {
            System.out.println( sd.doc );
        }
    }
    
}
