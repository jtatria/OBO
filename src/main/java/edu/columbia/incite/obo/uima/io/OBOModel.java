/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo.uima.io;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import com.google.common.collect.ImmutableMap;

/**
 *
 * @author José Tomás Atria <jtatria@gmail.com>
 */
public class OBOModel {
    
    public static final String DFLT_MARG_FILE = "marginals.txt";
    public static final String DFLT_NGRAM_FILE = "ngramdata.txt";
    
    static final String DIR = "/home/gorgonzola/data/ext/googlebooks-eng-gb-all-1gram-20120701/";
    static final String TOTALS_F = "marginals.txt";
    static final String NGRAMS_F = "ngramdata.tsv";
    static final fFormat FORMAT = fFormat.TSV;
    final int minLo = 1674;
    final int maxHi = 1913;
    
    final Map<String,int[]> frqMap;
    final int[] marginals;
    final Map<String,Double> cache = new ConcurrentHashMap<>();

    public OBOModel( String dir, String margFile, String ngramFile ) {
        try {
            frqMap    = ImmutableMap.copyOf( loadFreqs( dir, ngramFile ) );
            marginals = loadMarginals( dir, margFile );
        } catch ( IOException ex ) {
            throw new RuntimeException( ex );
        }
    }
    
    public double p( String term ) {
        return cache.computeIfAbsent( term, t -> extractP( t, minLo, maxHi ) );
    }
    
    public double extractP( String term, int lo, int hi ) {        
        int[] fSrc = frqMap.get( term );
        if( fSrc == null ) return -1;
        
        double d = 0;
        int ct = 0;
        for( int i = minLo - lo; i < ( hi - lo ); i++ ) {
            d += (double) fSrc[i] / (double) marginals[i];
            ct++;
        }
        
        return d / (double) ct;
    }
    
    private Map<String,int[]> loadFreqs( String dir, String file ) throws IOException {
        Path p = Paths.get( dir, file );
        
        Map<String,int[]> out = new ConcurrentHashMap<>();
        Files.lines( p, StandardCharsets.UTF_8 ).parallel().forEach(
            l -> {
                String[] split = l.split( "\\t" );
                String k = split[0];
                int[] f = new int[split.length - 1];
                for( int i = 0; i < split.length - 1; i++ ) {
                    f[i] = Integer.parseInt( split[i + 1] );
                }
                out.put( k, f );
            }
        );
        
        return out;
    }

    private int[] loadMarginals( String dir, String file ) throws IOException {
        Path p = Paths.get( dir, file );
        
        List<String> tmp = new ArrayList<>();
        Files.lines( p ).forEachOrdered( ( String l) -> {
            String[] split = l.split( "," );
            int year = Integer.parseInt( split[0] );            
            if( year < minLo ) return;
            if( year > maxHi ) return;
            tmp.add( split[1] );
        } );
        
        int[] out = new int[tmp.size()];
        for( int i = 0; i < out.length; i++ ) {
            out[i] = Integer.parseInt( tmp.get( i ) );
        }
        
        return out;
    }
    
    public enum fFormat {
        JSON,
        TSV,
        CSV,
    }
}
