using System;
using System.Runtime.InteropServices;
public static class MusicTaskbar {
 [StructLayout(LayoutKind.Sequential, Pack=4)] public struct Key { public Guid fmt; public uint pid; public Key(uint n){fmt=new Guid("9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3");pid=n;} }
 [StructLayout(LayoutKind.Explicit,Size=24)] public struct PV { [FieldOffset(0)] public ushort vt; [FieldOffset(8)] public IntPtr ptr; }
 [ComImport,Guid("886d8eeb-8cf2-4446-8d02-cdba1dbdcf99"),InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface Store {
  [PreserveSig] int GetCount(out uint count);
  [PreserveSig] int GetAt(uint i,out Key key);
  [PreserveSig] int GetValue(ref Key key,out PV value);
  [PreserveSig] int SetValue(ref Key key,ref PV value);
  [PreserveSig] int Commit();
 }
 [DllImport("shell32.dll")] static extern int SHGetPropertyStoreForWindow(IntPtr h,ref Guid iid,[MarshalAs(UnmanagedType.Interface)]out Store store);
 [DllImport("ole32.dll")] static extern int PropVariantClear(ref PV pv);
 public static string Read(long hwnd,uint id){
  Guid iid=typeof(Store).GUID;Store s;Marshal.ThrowExceptionForHR(SHGetPropertyStoreForWindow(new IntPtr(hwnd),ref iid,out s));
  try{Key k=new Key(id);PV v;Marshal.ThrowExceptionForHR(s.GetValue(ref k,out v));try{return v.vt==31 ? Marshal.PtrToStringUni(v.ptr) : "[vt="+v.vt+"]";}finally{PropVariantClear(ref v);}}finally{Marshal.ReleaseComObject(s);}
 }
 public static void Write(long hwnd,uint id,string text){
  Guid iid=typeof(Store).GUID;Store s;Marshal.ThrowExceptionForHR(SHGetPropertyStoreForWindow(new IntPtr(hwnd),ref iid,out s));
  try{Key k=new Key(id);PV v=new PV();if(text!=null){v.vt=31;v.ptr=Marshal.StringToCoTaskMemUni(text);}try{Marshal.ThrowExceptionForHR(s.SetValue(ref k,ref v));}finally{PropVariantClear(ref v);}}finally{Marshal.ReleaseComObject(s);}
 }
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] static extern IntPtr LoadImage(IntPtr instance,string name,uint type,int cx,int cy,uint flags);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] static extern IntPtr SendMessageTimeout(IntPtr hwnd,uint msg,IntPtr wp,IntPtr lp,uint flags,uint timeout,out UIntPtr result);
 static IntPtr small=IntPtr.Zero,big=IntPtr.Zero;
 public static void SetWindowIcons(long hwnd,string path){
  if(small==IntPtr.Zero){small=LoadImage(IntPtr.Zero,path,1,32,32,0x10);big=LoadImage(IntPtr.Zero,path,1,64,64,0x10);}
  UIntPtr result;SendMessageTimeout(new IntPtr(hwnd),0x80,IntPtr.Zero,small,2,200,out result);SendMessageTimeout(new IntPtr(hwnd),0x80,new IntPtr(1),big,2,200,out result);
 }}
