/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo;


import java.io.IOException;
import java.util.Properties;

import edu.columbia.incite.Conf;
import edu.columbia.incite.obo.uima.io.OBOMappingProvider;
import edu.columbia.incite.obo.uima.io.OBOSaxHandler;
import edu.columbia.incite.obo.uima.io.OBOSplitCheck;
import edu.columbia.incite.run.CPERunner;
import edu.columbia.incite.uima.io.BinaryReader;
import edu.columbia.incite.uima.io.XmlReader;
import edu.columbia.incite.uima.tools.InciteTextFilter;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 */
public class UIMAReadTEI {

    public static final String COLLECTION = "POB_7.2";
    
    public static final String MODEL_DIR = "/home/jta/data/ext/googlebooks-eng-gb-all-1gram-20120701/";
    
    public static void main( String[] args ) throws IOException, Exception {
        String urd = XmlReader.class.getName();
        String oxh = OBOSaxHandler.class.getName();
        String omp = OBOMappingProvider.class.getName();
        String chp = InciteTextFilter.class.getName();
        String sck = OBOSplitCheck.class.getName();
        String uwr = BinaryReader.class.getName();
        
        Properties props = new Properties();        
        
        props.setProperty( Conf.DFLT_NS + "." + Conf.PARAM_UIMA_READER, urd );
        props.setProperty( urd + "." + XmlReader.PARAM_COLLECTION_NAME, COLLECTION );
        props.setProperty( urd + "." + XmlReader.RES_SAX_HANDLER, oxh );
        props.setProperty( oxh + "." + OBOSaxHandler.RES_MAPPING_PROVIDER, omp );
        props.setProperty( oxh + "." + OBOSaxHandler.RES_CHAR_PROCESSOR, chp );
        props.setProperty( chp + "." + InciteTextFilter.RES_SPLIT_CHECK, sck );
        props.setProperty( sck + "." + OBOSplitCheck.PARAM_MODEL_DIR, MODEL_DIR );
        props.setProperty( Conf.DFLT_NS + "." + Conf.PARAM_UIMA_CONS, uwr );

        Conf conf = new Conf( Conf.DFLT_NS, props );
        CPERunner cper = new CPERunner( conf );
        cper.build();
        cper.call();
    }
    
}
