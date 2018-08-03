/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo;

import java.io.IOException;
import java.util.Properties;

import de.tudarmstadt.ukp.dkpro.core.stanfordnlp.StanfordLemmatizer;
import de.tudarmstadt.ukp.dkpro.core.stanfordnlp.StanfordPosTagger;
import de.tudarmstadt.ukp.dkpro.core.stanfordnlp.StanfordSegmenter;
import org.xml.sax.SAXException;

import edu.columbia.incite.Conf;
import edu.columbia.incite.run.CPERunner;
import edu.columbia.incite.uima.api.types.Paragraph;
import edu.columbia.incite.uima.io.BinaryReader;
import edu.columbia.incite.uima.io.BinaryWriter;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 */
public class UIMARunNLP {

    public static void main( String[] args ) throws IOException, SAXException, Exception {
        Properties props = new Properties();
        
        props.setProperty( Conf.PARAM_UIMA_READER, BinaryReader.class.getName() );
        props.setProperty( Conf.PARAM_UIMA_AES, String.join( ",", 
            StanfordSegmenter.class.getName(),
            StanfordPosTagger.class.getName(),
            StanfordLemmatizer.class.getName()
        ) );
        props.setProperty( StanfordSegmenter.PARAM_ZONE_TYPES, Paragraph.class.getName() );
        props.setProperty( StanfordSegmenter.PARAM_BOUNDARY_TOKEN_REGEX, "\\.|[!?]+|\u2014" );
        props.setProperty( StanfordSegmenter.PARAM_BOUNDARIES_TO_DISCARD, "\\n|\\*NL\\*|\u2014" );
        props.setProperty( StanfordSegmenter.PARAM_STRICT_ZONING, "true" );
        props.setProperty( Conf.PARAM_UIMA_CONS, BinaryWriter.class.getName() );
                
        Conf conf = new Conf( Conf.DFLT_NS, props );
        CPERunner cper = new CPERunner( conf );
        cper.build();
        cper.call();
    }
    
}
