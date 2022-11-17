/**
 * This is a comment
 */
public class Main {
  /**
   * Main entry point
   */
  public static void main(String... args) {
    String language = "english";

    if (args.length > 0) {
      System.out.println("args:");
      System.out.println("  " + args[0]);

      String lang = args[0].toLowerCase();
      if (lang.equals("spanish")) {
        language = "spanish";
      } else if (lang.equals("orkan")) {
        language = "orkan";
      } else if (lang.equals("bob")) {
        language = "bob";
      }
    }

    if (language.equals("spanish")) {
      System.out.println("¡Ola!");
    } else if (language.equals("english")) {
      System.out.println("Hello world!");
    } else if (language.equals("orkan")) {
      System.out.println("Na-nu, Na-nu^");
    } else if (language.equals("bob")) {
      System.out.println("Howdy, 'yall");
    }

    System.exit(1);
  }
}
