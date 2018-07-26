/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo.debug;

import java.io.IOException;
import java.io.Writer;

import org.apache.uima.analysis_engine.AnalysisEngineDescription;
import org.apache.uima.collection.CollectionProcessingEngine;
import org.apache.uima.collection.CollectionReaderDescription;
import org.apache.uima.collection.metadata.CpeDescriptorException;
import org.apache.uima.fit.cpe.CpeBuilder;
import org.apache.uima.fit.factory.AnalysisEngineFactory;
import org.apache.uima.fit.factory.CollectionReaderFactory;
import org.apache.uima.resource.ResourceInitializationException;
import org.apache.uima.util.InvalidXMLException;
import org.xml.sax.SAXException;

import edu.columbia.incite.uima.io.BinaryReader;
import edu.columbia.incite.uima.io.BinaryWriter;
import edu.columbia.incite.uima.io.XmiSerializer;
import edu.columbia.incite.run.CallbackListener;

/**
 *
 * @author José Tomás Atria <jtatria@gmail.com>
 */
public class FixDates {

    static {
        System.setProperty( "java.util.logging.config.file", "/home/jta/src/local/obo/obo-java/conf/log.conf/logging.properties" );
    }
    
    public static Writer W;
    
    public static void main( String[] args ) throws ResourceInitializationException, IOException, SAXException, CpeDescriptorException, InvalidXMLException {
        
        CollectionReaderDescription crd = CollectionReaderFactory.createReaderDescription( BinaryReader.class );
        
        AnalysisEngineDescription dateFix = AnalysisEngineFactory.createEngineDescription( DateFix.class );
        
        AnalysisEngineDescription xmiDump = AnalysisEngineFactory.createEngineDescription( 
            XmiSerializer.class 
            , XmiSerializer.PARAM_OUTPUT_DIR, "data/output/xmi"
        );
        
        AnalysisEngineDescription binDump = AnalysisEngineFactory.createEngineDescription( 
            BinaryWriter.class 
            , BinaryWriter.PARAM_OUTPUT_DIR, "data/output/bin"
        );
        
        AnalysisEngineDescription ae = AnalysisEngineFactory.createEngineDescription( dateFix, xmiDump );//, binDump );
//        AnalysisEngineDescription ae = dateFix;
        
        CpeBuilder cpb = new CpeBuilder();
        cpb.setMaxProcessingUnitThreadCount( 1 );
//        cpb.setMaxProcessingUnitThreadCount( 10 );
        cpb.setReader( crd );
        cpb.setAnalysisEngine( ae );
        CollectionProcessingEngine cpe = cpb.createCpe( new CallbackListener() );
        cpe.process();
    }
}
