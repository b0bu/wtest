package main

import (
	"html/template"
	"log"
	"net/http"
	"os"
	"regexp"
)

const dataPath = "data/"
const tmplPath = "tmpl/"

var templates = template.Must(template.ParseFiles(tmplPath+"edit.html", tmplPath+"view.html", tmplPath+"front.html"))
var validPath = regexp.MustCompile("^/(edit|save|view)/([a-zA-Z0-9]+)$")

type Page struct {
	Title   string
	Body    []byte
	Version string
}

func (p *Page) save() error {
	filename := p.Title + ".txt"
	return os.WriteFile(dataPath+filename, p.Body, 0600)
}

func loadPage(title string) (*Page, error) {
	filename := title + ".txt"
	version := os.Getenv("VERSION")
	body, err := os.ReadFile(dataPath + filename)
	if err != nil {
		return nil, err
	}
	return &Page{Title: title, Body: body, Version: version}, nil
}

func renderTemplate(w http.ResponseWriter, tmpl string, p *Page) {
	err := templates.ExecuteTemplate(w, tmpl+".html", p)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func defaultHandler(w http.ResponseWriter, r *http.Request, title string) {
	p, err := loadPage(title)
	// title could be anything but always send to /front
	if err != nil {
		http.Redirect(w, r, "/front/", http.StatusFound)
	}
	renderTemplate(w, "front", p)
}

func frontHandler(w http.ResponseWriter, r *http.Request) {
	p, _ := loadPage("front") // always exists
	renderTemplate(w, "front", p)
}

func viewHandler(w http.ResponseWriter, r *http.Request, title string) {
	p, err := loadPage(title)
	if err != nil {
		http.Redirect(w, r, "/edit/"+title, http.StatusFound)
	}
	renderTemplate(w, "view", p)
}

func editHandler(w http.ResponseWriter, r *http.Request, title string) {
	p, err := loadPage(title)
	if err != nil {
		p = &Page{Title: title}
	}
	renderTemplate(w, "edit", p)
}

func saveHandler(w http.ResponseWriter, r *http.Request, title string) {
	body := r.FormValue("body")
	p := &Page{Title: title, Body: []byte(body)}
	err := p.save()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/view/"+title, http.StatusFound)
}

func makeHandler(fn func(http.ResponseWriter, *http.Request, string)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		m := validPath.FindStringSubmatch(r.URL.Path)
		if m == nil {
			fn(w, r, "/front/") // let default do the redirect
			return
		}
		fn(w, r, m[2]) // the title is the second subexpression
	}
}

func main() {
	p := Page{Title: "default", Body: []byte("hello world")}
	p.save()

	http.HandleFunc("/", makeHandler(defaultHandler))
	http.HandleFunc("/view/", makeHandler(viewHandler))
	http.HandleFunc("/edit/", makeHandler(editHandler))
	http.HandleFunc("/save/", makeHandler(saveHandler))
	http.HandleFunc("/front/", frontHandler)

	log.Fatal(http.ListenAndServe(":8080", nil))
}
