public class Main {
  public static void main(String... args) {
    if (args.length > 0) {
      System.out.println("args:");
      System.out.println("  " + args[0]);
    }

    System.out.println("Hello world!");
    System.exit(0);
  }
}
