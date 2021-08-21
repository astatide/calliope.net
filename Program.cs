using System;
using System.Data.Common;
using System.Runtime.InteropServices;
using Calliope.NET.src.WeedGummy;

namespace Calliope.NET
{
    unsafe class Program
    {
        private delegate int chplMyFuncDelegate(int x);

        private delegate void chplInitDelegate(int argc, char* argv);

        private delegate int getArrayPositionDelegate(int dataSize, string dataName);

        [DllImport("helloWorld.so")]
        private static extern int myFunc(int x, chplMyFuncDelegate cl);

        [DllImport("helloWorld.so")]
        private static extern int createArray(int x);
        
        [DllImport("helloWorld.so")]
        private static extern int addToArray(int x);
        
        [DllImport("helloWorld.so")]
        private static extern int getArrayPosition(int dataSize, string dataName, getArrayPositionDelegate cl);
        
        [DllImport("helloWorld.so")]
        private static extern void chpl__init_CalliopeNET();
        
        [DllImport("helloWorld.so")]
        private static extern void chpl_library_init(int argc, string[] argv);
        
        
        [DllImport("helloWorld.so")]
        private static extern void chpl_library_finalize();
        
        private static int myFuncDelegate(int x)
        {
            Console.WriteLine("Eyyyyy", x);
            return 0;
        }

        private static int implementationGetArrayPositionDelegate(int dataSize, string dataName)
        {
            Console.WriteLine(dataSize);
            return dataSize;
        }

        private static void InitDelegate(int argc, char* argv)
        {
            Console.WriteLine(argc);
            Console.WriteLine(*argv);
        }
        
        static void Main(string[] args)
        {
            Console.WriteLine("Starting up Chapel");

            // Initialize the lib; we need to send in the argc, argv, which is an int and a char* array.
            // orrrrr just a string array, basically.
            string[] fakeString = {"fake"};
            chpl_library_init(1, fakeString);
            // we need to call our module's init function; this allows us to work with variables defined
            // outside the scope of the function.
            chpl__init_CalliopeNET();
            
            Console.WriteLine("Memory initialized; running external function");
            //myFunc(10, myFuncDelegate);
            //createArray(100000);
            //addToArray(100);
            Console.WriteLine(getArrayPosition(10, "test1", implementationGetArrayPositionDelegate));
            Console.WriteLine(getArrayPosition(100, "test2", implementationGetArrayPositionDelegate));
            Console.WriteLine(getArrayPosition(1000, "test3", implementationGetArrayPositionDelegate));
            Console.WriteLine(getArrayPosition(1000, "test3", implementationGetArrayPositionDelegate));

            AmAWeedGummy meinGummy = new AmAWeedGummy();
            AmAWeedGummy.PrintMyName();
            chpl_library_finalize();
        }
    }
}