import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      title: "Climbing Cookbook",
      defaultLocale: "root",
      locales: {
        root: { label: "English", lang: "en" },
        cz: { label: "Czech", lang: "cz" },
      },
      sidebar: [
        {
          label: "Welcome!",
          translations: {
            cz: "Vítejte!",
          },
          items: [
            "welcome/what_is_climbing_cookbook",
            "welcome/other_resources"
          ],
        },
        {
          label: "Recipes", 
          translations: {
            cz: "Návody",
          },
          autogenerate: { directory: "recipes" },
        },
      ],
    }),
  ],
});
