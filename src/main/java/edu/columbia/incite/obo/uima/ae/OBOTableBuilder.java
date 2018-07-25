/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.columbia.incite.obo.uima.ae;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.StandardCharsets;
import java.nio.file.DirectoryStream;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;

import com.google.common.collect.ImmutableMap;
import com.google.common.io.Files;
import org.apache.uima.UimaContext;
import org.apache.uima.analysis_engine.AnalysisEngineProcessException;
import org.apache.uima.cas.FSIterator;
import org.apache.uima.fit.descriptor.ConfigurationParameter;
import org.apache.uima.fit.util.JCasUtil;
import org.apache.uima.jcas.JCas;
import org.apache.uima.jcas.cas.FSArray;
import org.apache.uima.resource.ResourceInitializationException;

import edu.columbia.incite.run.Logs;
import edu.columbia.incite.uima.AbstractProcessor;
import edu.columbia.incite.uima.api.types.Paragraph;
import edu.columbia.incite.uima.api.types.Span;
import edu.columbia.incite.uima.api.types.Tuple;
import edu.columbia.incite.uima.api.types.obo.Charge;
import edu.columbia.incite.uima.api.types.obo.Date;
import edu.columbia.incite.uima.api.types.obo.Label;
import edu.columbia.incite.uima.api.types.obo.Legal;
import edu.columbia.incite.uima.api.types.obo.Named;
import edu.columbia.incite.uima.api.types.obo.OBOEntity;
import edu.columbia.incite.uima.api.types.obo.Offence;
import edu.columbia.incite.uima.api.types.obo.Person;
import edu.columbia.incite.uima.api.types.obo.Place;
import edu.columbia.incite.uima.api.types.obo.Section;
import edu.columbia.incite.uima.api.types.obo.Session;
import edu.columbia.incite.uima.api.types.obo.TrialAccount;
import edu.columbia.incite.uima.api.types.obo.Verdict;
import edu.columbia.incite.util.FileUtils;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 * 
 * TODO: generalize
 */
public class OBOTableBuilder extends AbstractProcessor {
   
    public static final String PARAM_OUTPUT_DIR = "outDir";
    @ConfigurationParameter( name = PARAM_OUTPUT_DIR, mandatory = false )
    private String outDir;
    
    public static final String PARAM_ESCAPE_SEPS = "escapeSeps";
    @ConfigurationParameter( name = PARAM_ESCAPE_SEPS, mandatory = false, defaultValue = "true" )
    private Boolean escapeSeps;
    
    public static final String FNAME_FORMAT = "%s.csv";
    public static final String PAY_ID = "_pay_id_";
    public static final String TGT_ID = "_tgt_id_";
    public static final String DEF_ID = "_def_id_";
    public static final String OFF_ID = "_off_id_";
    public static final String VER_ID = "_ver_id_";
    public static final String COL_SEP = "@";
    public static final String ROW_SEP = "\n";
    
    public static final int SES = 0;
    public static final int DIV = 1;
    public static final int OFF = 2;
    public static final int VER = 3;
    public static final int PUN = 4;
    public static final int PER = 5;
    public static final int PLA = 6;
    public static final int LAB = 7;
    public static final int JON = 8;
    public static final int CHA = 9;
    public static final int DAT = 10;
    public static final String[] TABLES = new String[]{
        "ses", "div", "off", "ver", "pun", "per", "pla", "lab", "jon", "cha", "dat"
    };
    
    public static final Map<String,String[]> HEADERS;
    static {
        Map<String,String[]> tmp = new HashMap<>();
            tmp.put( TABLES[SES], new String[]{
                "sesId", "sesType", "sesYear", "sesDate", "trialCt",
            } );
            tmp.put( TABLES[DIV], new String[]{
                "divId", "divType", "divYear", "divDate", "clen", "paraCt",
            } );
            tmp.put( TABLES[OFF], new String[]{
                "entId", "divId", "oboType", "cat", "subcat", "chars",
            } );
            tmp.put( TABLES[VER], new String[]{
                "entId", "divId", "oboType", "cat", "subcat", "chars",
            } );
            tmp.put( TABLES[PUN], new String[]{
                "entId", "divId", "oboType", "cat", "subcat", "chars",
            } );
            tmp.put( TABLES[PER], new String[]{
                "entId", "divId", "oboType", "given", "surname", "gender", "age", "occ", "chars",
            } );
            tmp.put( TABLES[PLA], new String[]{
                "entId", "divId", "plaType", "plaName", "chars",
            } );
            tmp.put( TABLES[LAB], new String[]{
                "entId", "divId", "oboType", "chars",
            } );
            tmp.put( TABLES[JON], new String[]{
                "type", "tgtId", "payId", "valid",
            } );
            tmp.put( TABLES[CHA], new String[]{
                "chaId", "divId", "defId", "offId", "verId", "valid",
            } );
            tmp.put( TABLES[DAT], new String[]{
                "entId", "divId", "oboType", "chars",
            } );
        HEADERS = ImmutableMap.copyOf( tmp );
    }

    private final static Set<Path> tmpDirs = new HashSet<>();
    private final static AtomicInteger aes = new AtomicInteger( 0 );
    
    private final Map<Session,Collection<Section>> sessions = new HashMap<>();
    private final Map<Section,Collection<Span>>    sections = new HashMap<>();
    private final Map<String,PrintStream> outFiles = new HashMap<>();
    
    @Override
    public void initialize( UimaContext ctx ) throws ResourceInitializationException {
        super.initialize( ctx );
        
        aes.getAndIncrement();
        
        Path myDir = Files.createTempDir().toPath();
        tmpDirs.add( myDir );
        
        outFiles.clear();
        for( String key : TABLES ) {
            String tid = Long.toString( Thread.currentThread().getId() );
            try {
                File table = File.createTempFile( key, tid, myDir.toFile() );
                outFiles.put( key, new PrintStream(
                    new FileOutputStream( table ), true, StandardCharsets.UTF_8.toString() 
                ) );
            } catch( IOException ex ) {
                throw new ResourceInitializationException( ex );
            }
        }
    }
    
    @Override
    protected void preProcess( JCas jcas ) throws AnalysisEngineProcessException {
        super.preProcess( jcas );
        this.sessions.putAll( JCasUtil.indexCovered( jcas, Session.class, Section.class ) );
        this.sections.putAll( JCasUtil.indexCovered( jcas, Section.class, Span.class ) );
    }
    
    @Override
    protected void realProcess( JCas jcas ) throws AnalysisEngineProcessException {
        for( Session ses : sessions.keySet() ) {
            int trialCt = 0;
            for( Section div : sessions.get( ses ) ) {
                String divId = div.getId();
                int paraCt = 0;
                Collection<Span> spans = sections.get( div );
                if( spans != null ) {
                    for( Span ann : sections.get( div ) ) {
                        if( ann instanceof OBOEntity ) {
                            OBOEntity ent  = (OBOEntity) ann;
                            String entId   = ent.getId();
                            if( ent instanceof Date ) {
                                addRecord(
                                    TABLES[DAT],
                                    entId,
                                    divId,
                                    ent.getOboType(),
                                    escape( ent.getCoveredText() )
                                );
                            } else if( ent instanceof Legal ) {
                                Legal lgl = (Legal) ent;
                                String type = lgl.getClass().getSimpleName();
                                String key = null;
                                switch( type ) {
                                    case "Offence":    key = TABLES[OFF]; break;
                                    case "Verdict":    key = TABLES[VER]; break;
                                    case "Punishment": key = TABLES[PUN]; break;
                                    default: throw new AssertionError();
                                }
                                addRecord( 
                                    key,
                                    entId,
                                    divId, 
                                    lgl.getOboType(),
                                    lgl.getCategory(),
                                    lgl.getSubcategory(),
                                    escape( lgl.getCoveredText() )
                                );
                            } else if( ent instanceof Named ) {
                                if( ent instanceof Person ) {
                                    Person per = (Person) ent;
                                    addRecord( 
                                        TABLES[PER],
                                        entId,
                                        divId,
                                        per.getOboType(),
                                        per.getGiven(),
                                        per.getSurname(),
                                        per.getGender(),
                                        per.getAge(),
                                        per.getOccupation(),
                                        escape( per.getCoveredText() )
                                    );
                                } else if( ent instanceof Place ) {
                                    Place pla = (Place) ent;
                                    addRecord( 
                                        TABLES[PLA],
                                        entId,
                                        divId,
                                        pla.getPlaceType(),
                                        pla.getPlaceName(),
                                        escape( pla.getCoveredText() )
                                    );
                                }
                            } else if( ent instanceof Label ) {
                                addRecord(
                                    TABLES[LAB],
                                    entId,
                                    divId,
                                    ent.getOboType(),
                                    escape( ent.getCoveredText() )
                                );
                            }
                        } else if( ann instanceof Paragraph ) {
                            paraCt++;
                        }
                    }    
                } else {
                    Logs.warnf( "No spans for div %s!", divId );
                }
                addRecord(
                    TABLES[DIV],
                    divId,
                    div.getOboType(),
                    div.getYear(),
                    div.getDate(),
                    Integer.toString( div.getCoveredText().length() ),
                    Integer.toString( paraCt )
                );
                
                if( div instanceof TrialAccount ) {
                    trialCt++;
                    TrialAccount trial = (TrialAccount) div;
                    FSArray charges = trial.getCharges();
                    if( charges != null ) {
                        for( int c = 0; c < charges.size(); c++ ) {
                            Charge cha  = (Charge) charges.get( c );
                            Person  def = cha.getDefendant();
                            Offence off = cha.getOffence();
                            Verdict ver = cha.getVerdict();
                            addRecord( 
                                TABLES[CHA],
                                cha.getChargeId(),
                                divId,
                                def != null ? def.getId() : DEF_ID,
                                off != null ? off.getId() : OFF_ID,
                                ver != null ? ver.getId() : VER_ID,
                                Boolean.toString( def != null && off != null && ver != null )
                            );
                        }
                    } else {
                        Logs.warnf( "No charges for trial %s!", divId );
                    }
                }
            }
            addRecord(
                TABLES[SES],
                ses.getId(),
                ses.getOboType(),
                ses.getYear(),
                ses.getDate(),
                Integer.toString( trialCt )
            );
        }
        
        FSIterator<Tuple> tuples = jcas.getAllIndexedFS( Tuple.class );
        while( tuples.hasNext() ) {
            Tuple t = tuples.next();
            Span tgt = t.getSubject();
            Span pay = t.getObject();
            addRecord(
                TABLES[JON],
                t.getPredicate(),
                tgt != null ? tgt.getId() : TGT_ID,
                pay != null ? pay.getId() : PAY_ID,
                Boolean.toString( tgt != null && pay != null )
            );
        }
    }
    
    @Override
    public void postProcess( JCas jcas ) throws AnalysisEngineProcessException {
        super.postProcess( jcas );
        this.sessions.clear();
        this.sections.clear();
    }
    
    @Override
    public void collectionProcessComplete() throws AnalysisEngineProcessException {
        for( PrintStream ps : outFiles.values() ) ps.close();        
        int rem = aes.decrementAndGet();
        if( rem <= 0 ) {
            try {
                mergeFiles( outDir );
            } catch( IOException ex ) {
                throw new AnalysisEngineProcessException( ex );
            }
        }
    }
    
    private void addRecord( String key, String... params ) {
        if( params.length != HEADERS.get( key ).length ) {
            Logs.errorf(
                "Wrong number of fields for %s: exp %d, got %d",
                key, HEADERS.get( key ).length, params.length
            );
        }
        String row = String.join( COL_SEP, params ) + ROW_SEP;
        outFiles.get( key ).append( row );
    }

    private static void mergeFiles( String outDir ) throws IOException {
        Logs.infof( "Merging table files from %d tmp dirs to %s", tmpDirs.size(), outDir );
        Map<String,FileChannel> out = new HashMap<>();
        for( String key : TABLES ) {
            Path path = FileUtils.getFilePath(
                outDir, String.format( FNAME_FORMAT, key ), true, true
            );
            FileChannel fc = FileChannel.open( path, 
                StandardOpenOption.CREATE, 
                StandardOpenOption.TRUNCATE_EXISTING,
                StandardOpenOption.WRITE 
            );
            String join = String.join( COL_SEP, HEADERS.get( key ) ) + ROW_SEP;
            ByteBuffer header = ByteBuffer.wrap( join.getBytes( StandardCharsets.UTF_8 ) );
            fc.write( header );
            out.put( key, fc );
        }
        for( Path dir : tmpDirs ) {
            DirectoryStream<Path> ds = java.nio.file.Files.newDirectoryStream( dir );
            for( Path p : ds ) {
                String key = p.getFileName().toString().substring( 0, 3 );
                FileChannel src = FileChannel.open( p, StandardOpenOption.READ );
                FileChannel tgt = out.get( key );
                src.transferTo( 0, src.size(), tgt );
                src.close();
            }
        }
        for( FileChannel fc : out.values() ) fc.close();
    }
    
    private String escape( String in ) {
        if( !escapeSeps ) return in;
        return in.replaceAll( ROW_SEP, " " ).replaceAll( COL_SEP, " " );
    }
}
