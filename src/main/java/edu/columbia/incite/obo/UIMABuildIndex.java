/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo;

import java.io.IOException;
import java.util.Properties;

import org.xml.sax.SAXException;

import edu.columbia.incite.Conf;
import edu.columbia.incite.obo.corpus.OBODocFields;
import edu.columbia.incite.obo.corpus.OBOTokenFields;
import edu.columbia.incite.run.CPERunner;
import edu.columbia.incite.uima.index.CorpusIndexer;
import edu.columbia.incite.uima.index.LuceneIndexWriter;
import edu.columbia.incite.uima.io.BinaryReader;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 */
public class UIMABuildIndex {

    public static void main( String[] args ) throws IOException, SAXException, Exception {
        Properties props = new Properties();
        
        props.setProperty( Conf.PARAM_UIMA_READER, BinaryReader.class.getName() );
        props.setProperty( Conf.PARAM_UIMA_AES, String.join( ",", 
            CorpusIndexer.class.getName()
        ) );
        props.setProperty( CorpusIndexer.RES_INDEX_WRITER, LuceneIndexWriter.class.getName() );
        props.setProperty( CorpusIndexer.RES_STREAMS, OBOTokenFields.class.getName() );
        props.setProperty( CorpusIndexer.RES_LUCENEFB, OBODocFields.class.getName() );
        
        Conf conf = new Conf( props );
        CPERunner cper = new CPERunner( conf );
        cper.build();
        cper.call();
    }
    
}
