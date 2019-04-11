import std.stdio;
import core.stdc.locale : setlocale, LC_ALL, LC_MESSAGES;
import std.algorithm.sorting : sort;
import std.string;
import std.array;

import menu;


struct IceMenu {
    Menu m;
    int[string] known_cats;
    ApplicationFile[][string] grouped;
    string[] sorted_cates;

    void read() {
        m.read();
    }
    
    void write_menu() {
        remove_reserved_applications();
        group_by_category();

        //
        string[] sorted_cats = grouped.keys();        
        sorted_cats.sort();

        alias appCmp = (x, y) => x.Name < y.Name;

        //
        foreach(cat; sorted_cats) {
            auto apps = grouped[cat];
            apps.sort!(appCmp).release;
            
            bool use_locale_cat = false;
            string catname;
            if (use_locale_cat) {
                catname = cat in m.categories.cats ? 
                    (m.categories.cats[cat].NameLC.empty ? m.categories.cats[cat].Name : m.categories.cats[cat].NameLC) : cat;
            } else {
                catname = cat;
            }

            //
            //string menu_icon = (cat in m.categories.cats) ? m.categories.cats[cat].icon : "folder";
            string menu_icon = (cat in m.categories.cats) ? m.categories.cats[cat].Icon : "file-manager";
            writeln("menu ", cat, " ", menu_icon, " {");
            
            //
            foreach (app; apps) {
                string name;
                bool use_locale = false;

                // 
                if (use_locale) {
                    name = !app.NameLC.empty ? app.NameLC : app.Name;
                } else {
                    name = app.Name;
                }
                
                //
                string icon;
                icon = !app.Icon.empty ? app.Icon : "!";
                
                //
                string exec;

                if (app.Type == "Link") {
                    exec = "x-www-browser " ~ app.URL;
                    
                } else
                if (app.Terminal) {
                    exec = "x-terminal-emulator -e " ~ app.Exec;
                    
                } else {
                    exec = app.Exec;
                }                
                
                //
                exec = exec.replace("%U", "");
                exec = exec.replace("%u", "");
                exec = exec.replace("%F", "");
                exec = exec.replace("%f", "");

                //
                writeln("  prog ", "\"", name, "\"", " ", icon, " ", exec);
            }

            //
            writeln("}");
        }

    }

    void remove_reserved_applications() {
        string[] rs = m.reserved_categories();
        
        Applications new_collection;
        
        foreach (name, app; m.applications.apps) {
            foreach (r; rs) {
                if (app.Categories.split(";").find(r).empty) {
                    new_collection.apps[app.Name] = app;
                }
            }
        }
        
        m.applications = new_collection;
    }
    
    ApplicationFile[] sort_apps_by_name(ApplicationFile[] apps) {
        return apps;
    }
    
    void group_by_category() {
        string[] regs = m.registered_categories();

        foreach (name, app; m.applications.apps) {
            auto cats = m.get_category(app.Categories);
            bool found = false;
            
            foreach (r; regs) {
                if (!cats.find(r).empty) {
                    grouped[r] ~= app;
                    found = true;
                }
            }
            
            if (!found) {
                grouped["Other"] ~= app;
            }
        }
    }
    
    void make_known_cats() {
        foreach (name, app; m.applications.apps) {
            //writeln(app.name, ": ", app.exec);
            //writeln(app.lcname, ": ", app.categories);
            //writeln("prog ", "\"", app.name, "\"", " ", app.icon, " ", app.exec);
            
            auto cats = m.get_category(app.Categories);
            
            foreach (cat; cats) {
                known_cats[cat] = 1;
            }            
        }
    }
}

void main() {
        char* loc = setlocale (LC_MESSAGES, "");

        IceMenu im;
        im.read();
        im.write_menu();
}
