# Copyright (c) Microsoft Corporation.  All rights reserved.
#
# Usage:
#   Do not use, go to the ese dev root, and call gengen.bat
#

$jetapifile = 'src\ese\sysparamtable.g.cxx';
open(my $jetapifileHandle, "<", $jetapifile) or die "Can't open $jetapifile!";

my $public = 0;
my %publicApis;
my $publicApiCount = 0;
my $privateApiCount = 0;
my $lineNumber = 0;

my %publishedParams;
my %pointerSizeParams;

# Build up the list of private/public JET_params.
while ($line = <>)
{
    $lineNumber++;
#    print "$lineNumber: $line";

    if ($line =~ /begin_PubEsent/)
    {
        # print "Switch to public on line $lineNumber.\n";
        $public = 1;
    }
    elsif ($line =~ /end_PubEsent/)
    {
        # print "Switch to private on line $lineNumber.\n";
        $public = 0;
    }
    elsif ($line =~ /^#define JET_param(\w+)/)
    {
        if ($public)
        {
            # print "Found a public parameter: $1\n";
            $publicApis{$1} = 1;
            ++$publicApiCount;
        }
        else
        {
            # print "Found a private parameter: $1\n";
            ++$privateApiCount;
        }
    }
    else
    {
        # print "Not matched: $lineNumber: $line.\n";
    }
}
# print "Processed $lineNumber lines of $jetapifile. $privateApiCount private params found and $publicApiCount public params.\n";

foreach $param ( 
            'SystemPath',
            'TempPath',
            'LogFilePath',
            'BaseName',
            'EventSource',
            'MaxSessions',
            'MaxOpenTables',
            'MaxCursors',
            'MaxVerPages',
            'MaxTemporaryTables',
            'LogFileSize',
            'LogBuffers',
            'CircularLog',
            'DbExtensionSize',
            'PageTempDBMin',
            'CacheSizeMax',
            'CheckpointDepthMax',
            'OutstandingIOMax',
            'StartFlushThreshold',
            'StopFlushThreshold',
            'Recovery',
            'EnableOnlineDefrag',
            'CacheSize',
            'EnableIndexChecking',
            'EventSourceKey',
            'NoInformationEvent',
            'EventLoggingLevel',
            'DeleteOutOfRangeLogs',
            'EnableIndexCleanup',
            'CacheSizeMin',
            'PreferredVerPages',
            'DatabasePageSize',
            'CleanupMismatchedLogFiles',
            'ExceptionAction',
            'CreatePathIfNotExist',
            'OneDatabasePerSession',
            'MaxInstances',
            'VersionStoreTaskQueueMax',
            'Configuration',
            'KeyMost')
{
    # print "Adding the parameter $param to the publishedParams hash.\n";
    $publishedParams{ $param } = 1;
}

foreach $param ( 'Configuration',
                 'KeyMost' )
{
    # print "Adding the parameter $param to the vistaParams hash.\n";
    $vistaParams{ $param } = 1;
}

# These are 64bit-sized on 64bit platforms.
foreach $param ( 'CheckpointDepthMax',
                 'KeyMost' )
{
    # print "Adding the parameter $param to the pointerSizeParams hash.\n";
    $pointerSizeParams{ $param } = 1;
}

# Print the header of the file.
print <<__PROLOG__;
//-----------------------------------------------------------------------
// <copyright file="SystemParameters.cs" company="Microsoft Corporation">
//     Copyright (c) Microsoft Corporation.
// </copyright>
//-----------------------------------------------------------------------

// <remarks>
// Generated by params.pl
// </remarks>
namespace Microsoft.Database.Isam
{
    using System;
    using Microsoft.Isam.Esent.Interop;
    using Microsoft.Isam.Esent.Interop.Vista;

    /// <summary>
    /// Properties for per-instance system parameters
    /// </summary>
    public class IsamSystemParameters
    {
        /// <summary>
        /// The instance.
        /// </summary>
        private readonly IsamInstance instance;

        /// <summary>
        /// Initializes a new instance of the <see cref="IsamSystemParameters"/> class.
        /// </summary>
        /// <param name="instance">The instance.</param>
        internal IsamSystemParameters(IsamInstance instance)
        {
            this.instance = instance;
        }
__PROLOG__

while(<$jetapifileHandle>) {
    $_ =~ s/\s+//g;

    $fmatch = 0;

    if(/NORMAL_PARAM2?\(JET_param(\w+),CJetParam::type(\w+),[^,]+,(\d),(\d),(\d)/) {
        $param                          = $1;
        $type                           = $2;
        $readonly                       = 0;
        $global                         = $3;
        $maynotwriteafterglobalinit     = $4;
        $maynotwriteafterinstanceinit   = $5;
        $fmatch                         = 1;

        if( exists $hash{$param} ) {
            next;
        }
        $hash{$param} = $type;
    }

    if(/CUSTOM_PARAM\(JET_param(\w+),CJetParam::type(\w+),[^,]+,(\d),(\d),(\d),[^,]+,([^,]+),[^,]+/) {
        $param                          = $1;
        $type                           = $2;
        $readonly                       = $6 eq "CJetParam::IllegalSet" ? 1 : 0;
        $global                         = $3;
        $maynotwriteafterglobalinit     = $4;
        $maynotwriteafterinstanceinit   = $5;
        $fmatch                         = 1;

        if( exists $hash{$param} ) {
            next;
        }
        $hash{$param} = $type;
    }

    if(/CUSTOM_PARAM2\(JET_param(\w+),CJetParam::type(\w+),[^,]+,(\d),(\d),(\d),[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),[^,]+/) {
        $param                          = $1;
        $type                           = $2;
        $readonly                       = $6 eq "CJetParam::IllegalSet" ? 1 : 0;
        $global                         = $3;
        $maynotwriteafterglobalinit     = $4;
        $maynotwriteafterinstanceinit   = $5;
        $fmatch                         = 1;

        if( exists $hash{$param} ) {
            next;
        }
        $hash{$param} = $type;
    }

    if(/CUSTOM_PARAM3\(JET_param(\w+),CJetParam::type(\w+),[^,]+,(\d),(\d),(\d),[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),[^,]+/) {
        $param                          = $1;
        $type                           = $2;
        $readonly                       = $6 eq "CJetParam::IllegalSet" ? 1 : 0;
        $global                         = $3;
        $maynotwriteafterglobalinit     = $4;
        $maynotwriteafterinstanceinit   = $5;
        $fmatch                         = 1;

        if( exists $hash{$param} ) {
            next;
        }
        $hash{$param} = $type;
    }

    if(/READONLY_PARAM\(JET_param(\w+),CJetParam::type(\w+)/) {
        $param                          = $1;
        $type                           = $2;
        $readonly                       = 1;
        $global                         = 1;
        $maynotwriteafterglobalinit     = 1;
        $maynotwriteafterinstanceinit   = 1;
        $fmatch                         = 1;

        if( exists $hash{$param} ) {
            next;
        }
        $hash{$param} = $type;
    }

    if (!$fmatch)
    {
        # No match. Go on to the next line.
        next;
    }

    if ( $publishedParams{$param} != 1 )
    {
        # print "$param is a parameter that has not been ported to ManagedEsent.\n";
        next;
    }
    elsif ($publicApis{$param} == 1)
    {
        # print "$param is a public parameter.\n";
    }
    else
    {
        # print "$param is a PRIVATE parameter. Skipping.\n";
        next;
    }

    if( $type eq "Folder" || $type eq "Path" || $type eq "String" ) {
        $type = "string";
    }

    if( $type eq "Grbit" || $type eq "Integer" || $type eq "BlockSize" ) {
        $type = "int";
    }

    if( $type eq "Boolean" ) {
        $type = "bool";
    }

    if ( $type eq "int" && ( $pointerSizeParams{$param} == 1 ) )
    {
       $type = "long";
    }

    if ( $global && $maynotwriteafterglobalinit ) {
        $readonly = 1;
    }

    if( $fmatch ) {
#       print "$param is of type $type\n";
        my $GetsOrSetsString = $readonly ? "Gets" : "Gets or sets";
        my $paramPrefix = ( $vistaParams{$param} == 1 ) ? "VistaParam" : "JET_param";

        if( $type eq "string" ) {

print <<__EOCODE1__;

        /// <summary>
        /// $GetsOrSetsString system parameter which is a string.
        /// </summary>
        public $type $param
        {
            get
            {
                int ignored = 0;
                string val;
                Api.JetGetSystemParameter(this.instance.Inst, JET_SESID.Nil, $paramPrefix.$param, ref ignored, out val, 1024);
                return val;
            }
__EOCODE1__
            if( !$readonly ) {
print <<__EOCODE2__;

            set
            {
                Api.JetSetSystemParameter(this.instance.Inst, JET_SESID.Nil, $paramPrefix.$param, 0, value);
            }
__EOCODE2__
            }
print <<__EOCODE3__;
        }
__EOCODE3__
        }

        if( $type eq "int" || $type eq "long" ) {

print <<__EOCODE4__;

        /// <summary>
        /// $GetsOrSetsString a system parameter which is an integer type ($type).
        /// </summary>
        public $type $param
        {
            get
            {
                IntPtr val = IntPtr.Zero;
                string ignored;
                Api.JetGetSystemParameter(this.instance.Inst, JET_SESID.Nil, $paramPrefix.$param, ref val, out ignored, 0);
                return unchecked(($type)val);
            }
__EOCODE4__
            if( !$readonly ) {
print <<__EOCODE5__;

            set
            {
                Api.JetSetSystemParameter(this.instance.Inst, JET_SESID.Nil, $paramPrefix.$param, new IntPtr(value), null);
            }
__EOCODE5__
            }
print <<__EOCODE6__;
        }
__EOCODE6__
        }

        if( $type eq "bool" ) {

print <<__EOCODE7__;

        /// <summary>
        /// $GetsOrSetsString a value indicating whether the underlying system parameter is true.
        /// </summary>
        public $type $param
        {
            get
            {
                int val = 0;
                string ignored;
                Api.JetGetSystemParameter(this.instance.Inst, JET_SESID.Nil, $paramPrefix.$param, ref val, out ignored, 0);
                return 0 != val;
            }
__EOCODE7__
            if( !$readonly ) {
print <<__EOCODE8__;

            set
            {
                int val = value ? 1 : 0;
                Api.JetSetSystemParameter(this.instance.Inst, JET_SESID.Nil, $paramPrefix.$param, val, null);
            }
__EOCODE8__
            }
print <<__EOCODE9__;
        }
__EOCODE9__
        }

    }
}

print <<__EPILOG__;
    }
}
__EPILOG__