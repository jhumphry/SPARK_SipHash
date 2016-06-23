# SPARK_SipHash

## Introduction

This is an Ada 2012 / SPARK 2014 project that implements the
[SipHash](https://131002.net/siphash/) keyed hash function. SipHash was
designed by Jean-Philippe Aumasson and Daniel J. Bernstein, although
this implementation is independent of them. SipHash is a hash function
optimised for speed on short messages, but which uses modern
cryptographic design concepts in order to be as close to a true PRF
(Pseudo-Random Function) as possible.

This project is free software (ISC permissive licence) and is provided
with no warranties, as set out in the file LICENSE. The original
reference C code was released by the designers under the CC0 license, a
public domain-like license. A copy is provided as
`src/tests/reference_siphash_24.c` and is only used to check that the
Ada library produces results which match the reference implementation.

## Rationale - Hash-flooding DoS protection

A hash-flooding Denial of Service attack occurs when an attacker is
able to inject values under chosen keys into a hash table, for example
by making requests for resources which he knows will be tracked in a
hash table using the requested resource name as the key. If the hash
function is not secure, it may be possible to *deliberately* choose
names/keys which will all hash to the same bucket. Searches of the hash
table performed by the server software will only use this bucket and so
will start to take O(n) time, rather than the constant O(1) time which
hash tables usually achieve (on average). A server that might, in normal
use, appear to be generously over-provisioned can be slowed to a crawl
using only limited network resources.

There are several very fast hash functions that are perfectly adequate
for hash table use in safe environments but which are unsafe if exposed
to possible hash-flooding attacks. SipHash resists these attacks in two
ways. Firstly, it is not a single hash function but a (very large)
family of hash functions parametised by a key. Secondly, it is designed
to make it as hard as possible to find collisions, even if the attacker
can gather some information about the use of the hash. SipHash is also
fast enough to be competitive for hash table use. SipHash is probably
not suitable for most general purpose cryptographic uses due to the
small output size.

This project is an implementation in SPARK 2014 which provides a
verified implementation of SipHash. The verification does not address
the cryptographic properties of the hash, but concentrates on proving
the lack of classes of errors such as overflows. The result should be
sufficiently trustworthy to function as a drop-in replacement for
`Ada.Strings.Hash` in conjunction with `Ada.Containers`.

## Overview of the packages

The packages provide both generic versions of SipHash and
instantiations using typical parameters. Typical use will involve
calling a routine in `SipHash24.System_Entropy` to set a random key
using a system entropy source, and using one of the hash routines in
`SipHash24_String_Hashing` for an instantiation of the hash containers
in `Ada.Containers`.

### Package `SipHash`

This is the main generic package that implements the algorithm as
described in the original paper. The parameters `c_rounds` and
`d_rounds` allow the specification of the parameters labelled `c` and
`d` in the paper. The default key is also specified in `k0` and `k1`.

The `Set_Key` procedures allow the key to be set either from a
`Storage_Array` of length 16, or from two unsigned 64-bit modular types.
The key is part of the package state, as for the intended uses of this
project it is not necessary to be able to stipulate the key for each
hash operation.

It is important to *set the key to a value that cannot be predicted by
an attacker*. The easiest way of achieving this is to set a random key
when the software starts up. Most systems have facilities for producing
random numbers suitable for this purpose - see the `SipHash.Entropy`
package.

The `SipHash` function is responsible for producing a hash of an input
block of memory in the form of a `Storage_Array`. The output is a
64-bit modular value.

### Packages `SipHash.Discrete`, `SipHash.Wide_Discrete` and `SipHash.Wide_Wide_Discrete`

These generic functions allow the calculation of SipHash over arrays of
discrete types that fit into 1, 2 and 4 bytes respectively. They can
therefore be instantiated for the various string types. The output hash
type can also be chosen. This is necessary to ensure the instantiated
function has the right output to be used with `Ada.Containers`. In most
imaginable Ada runtimes, this will involve (internally) truncating the
native 64-bit output of SipHash to fit.

### Package `SipHash.General`

This generic package can hash any type by using `Storage_IO` to turn
values into a `Storage_Array`. Once again, the output hash type can be
chosen.

### Package `SipHash.Entropy`

This package provides routines to indicate if a system entropy source is
available, and to attempt to set the SipHash key using it. Three
implementations of this package are currently included, one that assumes no
system entropy source is available, one that uses `/dev/urandom` on Linux or
other Unix-like systems and one that uses the `getrandom` system call on
Linux. A suitable implementation should be compiled into the library to
provide randomisation - if an attacker can predict the key used for SipHash,
the benefit provided by using the package will be very limited.

Note that the facilities in `Ada.Numerics.Discrete_Random` may not be
sufficient to set the key. The time-dependent reset function may lead
to a different key on each execution, but if the approximate server
start time can be guessed the number of possible keys will be limited.
The implementation requirements in ARM A.5.2 and ARM G.2.5 relate to
the statistical quality of the output, not the cryptographic quality.

### Packages `SipHash24`, `SipHash24.System_Entropy`

These are instantiations of `SipHash` and `SipHash.Entropy` using the
standard (c => 2, d => 4) parameters recommended in the SipHash paper.

### Package `SipHash24_String_Hashing`

This package contains a range of routines for hashing `String`,
`Wide_String`, `Wide_Wide_String` and `UTF_8_String` in both
case-sensitive and case-insensitive variants.

### Packages in `src/general-provable`

These packages are not compiled into the library in normal conditions,
but exist to address an issue with the formal verification of
`SipHash.General` described in a later section.

## Project files and examples

A project file `spark_siphash.gpr` has been provided for use with GNAT and
GNATprove. This takes two parameters. The `mode` parameter can be set to
`debug` or `optimize` to produce the library itself with GNAT, or set to
`analyze` (equivalently - `analyse`) to use settings suitable for use with
GNATprove. The `entropy` parameter can be set to the desired implementation of
`SipHash.Entropy`. Currently the choices are `getrandom` to use this system
call on Linux, `urandom` to use `/dev/urandom`, or `none` to compile a null
implementation that raises an exception.

The project file `spark_siphash_external.gpr` enables use of the
library in external projects without prompting the builder to recompile
it.

The project file `spark_siphash_examples.gpr` can be used to compile
two example programs. `test_siphash.adb` ensures that the Ada routine
produces the same output as the reference C implementation for the test
vector described in the SipHash paper, a sample 'Lorem Ipsum' string,
and a series of arbitrary memory blocks of each length from 1 to 2,000
bytes. `example_hashed_maps.adb` demonstrates the use of this project
with the Ada standard library containers.

## Using GNATprove for verification

A standard invocation of GNATprove on this project is:

    gnatprove -P spark_siphash.gpr -Xmode=analyze -Xentropy=none

This uses standard settings that are equivalent to:

    gnatprove -P spark_siphash.gpr -Xmode=analyze -Xentropy=none -j0 --timeout=5 --level=2 --proof=progressive --warnings=continue

The settings should be adjusted based on the speed of your system.

SPARK does not fully analyse generic packages. The proofs are therefore
generated for the specific instantiations in the `SipHash24` packages,
which cover the common use cases of hasing strings and storage blocks.

### SPARK and Ada.Storage_IO

SPARK is incompatible with `Ada.Storage_IO`, as the latter has no SPARK
annotations and implementations of the package tend to use
SPARK-unfriendly methods such as access values and unchecked
conversions. It is therefore not possible to directly verify
`SipHash.General` due to its reliance on `Storage_IO`.

The solution found was to make a copy of `SipHash.General` called
`SipHash.General_SPARK` which uses a simplified version of `Storage_IO`
with the appropriate annotations to allow GNATprove to understand the
specification but to prevent GNATprove from analysing the body. An
instantiation of this package is also proved to act as a target for
GNATprove. Running a `diff` between `SipHash.General` and
`SipHash.General_SPARK` shows how minimal the differences are, and so
provides a justification for believing that the proof of the latter
provides evidence of the correctness of the former.

These files are stored in `src/general-provable` and the project file
is designed so they are only visible when `-Xmode=analyze` is passed to
GNAT or GNATprove. They are not compiled into the library in the `debug`
or `optimize` modes.
