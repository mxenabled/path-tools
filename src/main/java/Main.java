/**
 * This is a comment
 */
public class Main {
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
      }
    }

    if (language.equals("spanish")) {
      System.out.println("¡Ola!");
    } else if (language.equals("english")) {
      System.out.println("Hello world!");
    } else if (language.equals("orkan")) {
      System.out.println("Na-nu, Na-nu^");
    }

    System.exit(1);
  }
}
