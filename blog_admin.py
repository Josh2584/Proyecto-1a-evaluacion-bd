from __future__ import annotations
import re
import tkinter as tk
from dataclasses import dataclass
from tkinter import messagebox, ttk
from typing import Any

#La aplicación solo pide la contraseña.

#Usuario: blog_app
#Contraseña: BlogApp_2026!
#Host: localhost
#Puerto: 1521
#Nombre del servicio: FREEPDB1

import oracledb

EMAIL_RE = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")
SLUG_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
MAX_TEXT = 1000

DB_HOST = "localhost"
DB_PORT = 1521
DB_SERVICE = "FREEPDB1"
DB_USER = "blog_app"


class ValidationError(ValueError):
    pass


# Revisa que un texto obligatorio tenga contenido y el tamaño permitido.
def text(value: str, label: str, max_len: int, minimum: int = 1) -> str:
    value = value.strip()
    if len(value) < minimum:
        raise ValidationError(f"{label} es obligatorio.")
    if len(value) > max_len:
        raise ValidationError(f"{label} no puede superar {max_len} caracteres.")
    return value

# Revisa que los IDs escritos por el usuario sean números positivos.
def number(value: str, label: str, optional: bool = False) -> int | None:
    value = value.strip()
    if not value and optional:
        return None
    if not value.isdecimal() or int(value) < 1:
        raise ValidationError(f"{label} debe ser un identificador positivo.")
    return int(value)

# Convierte un error de Oracle en un mensaje fácil de mostrar en pantalla.
def oracle_message(error: Exception) -> str:
    if isinstance(error, oracledb.Error):
        info = error.args[0]
        return getattr(info, "message", str(error)).strip()
    return str(error)

class ConnectionDialog(tk.Toplevel):
    def __init__(self, app: "BlogApp"):
        super().__init__(app)
        self.app = app
        self.title("Conectar con Oracle")
        self.resizable(False, False)
        self.transient(app)
        self.grab_set()
        self.configure(padx=28, pady=24, bg="#000000")
        self.password = tk.StringVar()
        ttk.Label(self, text="Blog Oracle", style="Title.TLabel").grid(row=0, column=0, columnspan=2, sticky="w", pady=(0, 5))
        ttk.Label(self, text=f"{DB_USER}@{DB_HOST}:{DB_PORT}/{DB_SERVICE}", style="Hint.TLabel").grid(row=1, column=0, columnspan=2, sticky="w", pady=(0, 18))
        ttk.Label(self, text="Contraseña").grid(row=2, column=0, sticky="w", pady=5)
        password_entry = ttk.Entry(self, textvariable=self.password, width=34, show="•")
        password_entry.grid(row=2, column=1, padx=(14, 0), pady=5)
        ttk.Button(self, text="Conectar", style="Accent.TButton", command=self.connect).grid(row=3, column=1, sticky="e", pady=(18, 0))
        self.bind("<Return>", lambda _: self.connect())
        password_entry.focus_set()

    def connect(self):
        try:
            # La contraseña se usa para conectarse y no se almacena.
            password = text(self.password.get(), "Contraseña", 512)
            conn = oracledb.connect(user=DB_USER, password=password, dsn=f"{DB_HOST}:{DB_PORT}/{DB_SERVICE}", tcp_connect_timeout=8)
            self.app.set_connection(conn, f"{DB_USER}@{DB_HOST}:{DB_PORT}/{DB_SERVICE}")
            self.destroy()
        except (ValidationError, oracledb.Error) as exc:
            messagebox.showerror("No fue posible conectar", oracle_message(exc), parent=self)


@dataclass(frozen=True)
class Entity:
    key: str
    title: str
    columns: tuple[tuple[str, str, int], ...]
    table: str
    pk: str
    package: str


ENTITIES = (
    Entity("users", "Usuarios", (("Nombre completo", "Full_Name", 100), ("Correo", "Email", 254)), "Blog_Users", "User_Id", "user"),
    Entity("categories", "Categorias", (("Nombre", "Name", 80), ("Enlace", "Slug", 80)), "Blog_Categories", "Category_Id", "category"),
    Entity("tags", "Etiquetas", (("Nombre", "Name", 60), ("Enlace", "Slug", 60)), "Blog_Tags", "Tag_Id", "tag"),
)


class SimpleTab(ttk.Frame):
    def __init__(self, parent: ttk.Notebook, app: "BlogApp", entity: Entity):
        super().__init__(parent, padding=18)
        self.app, self.entity, self.selected_id = app, entity, None
        self.values = {field: tk.StringVar() for _, field, _ in entity.columns}
        form = ttk.LabelFrame(self, text=f"Datos de {entity.title[:-1].lower()}", padding=14)
        form.pack(fill="x")
        for col, (label, field, _) in enumerate(entity.columns):
            ttk.Label(form, text=label).grid(row=0, column=col * 2, sticky="w", padx=(0, 7))
            ttk.Entry(form, textvariable=self.values[field], width=30).grid(row=0, column=col * 2 + 1, sticky="ew", padx=(0, 16))
        buttons = ttk.Frame(form)
        buttons.grid(row=1, column=0, columnspan=6, sticky="w", pady=(14, 0))
        for label, action, style in (("Nuevo", self.clear, "TButton"), ("Guardar", self.save, "Accent.TButton"), ("Eliminar", self.delete, "Danger.TButton")):
            ttk.Button(buttons, text=label, command=action, style=style).pack(side="left", padx=(0, 8))
        self.tree = self.make_tree()
        self.tree.pack(fill="both", expand=True, pady=(16, 0))
        self.tree.bind("<<TreeviewSelect>>", self.select)

    def make_tree(self) -> ttk.Treeview:
        names = ("ID",) + tuple(label for label, _, _ in self.entity.columns)
        tree = ttk.Treeview(self, columns=names, show="headings", selectmode="browse", height=14)
        for name in names:
            tree.heading(name, text=name)
            tree.column(name, width=130 if name == "ID" else 250, anchor="w")
        return tree

    def load(self):
        if not self.app.conn: return
        fields = ", ".join((self.entity.pk,) + tuple(field for _, field, _ in self.entity.columns))
        rows = self.app.query(f"SELECT {fields} FROM {self.entity.table} ORDER BY {self.entity.pk}")
        self.tree.delete(*self.tree.get_children())
        for row in rows: self.tree.insert("", "end", values=row)

    def select(self, _=None):
        chosen = self.tree.selection()
        if not chosen: return
        row = self.tree.item(chosen[0], "values")
        self.selected_id = int(row[0])
        for (_, field, _), value in zip(self.entity.columns, row[1:]): self.values[field].set(value)

    def validate(self) -> list[str]:
        data = [text(self.values[field].get(), label, size) for label, field, size in self.entity.columns]
        if self.entity.key == "users" and not EMAIL_RE.fullmatch(data[1]): raise ValidationError("Ingresa un correo electrónico válido.")
        if self.entity.key in {"tags", "categories"} and not SLUG_RE.fullmatch(data[1].lower()): raise ValidationError("El enlace corto solo acepta minúsculas, números y guiones simples.")
        return data

    def save(self):
        try:
            data = self.validate()
            if self.selected_id is None:
                new_id = self.app.call_create(f"Blog_Pkg.create_{self.entity.package}", data)
                self.app.status(f"{self.entity.title[:-1]} creado con ID {new_id}.")
            else:
                self.app.call(f"Blog_Pkg.update_{self.entity.package}", [self.selected_id] + data)
                self.app.status("Cambios guardados.")
            self.app.commit_changes(); self.clear(); self.load()
        except (ValidationError, oracledb.Error, RuntimeError) as exc: self.app.error(exc)

    def delete(self):
        if self.selected_id is None: return self.app.warn("Selecciona un registro para eliminar.")
        if not messagebox.askyesno("Confirmar eliminación", "¿Eliminar el registro seleccionado?", parent=self): return
        try:
            self.app.call(f"Blog_Pkg.delete_{self.entity.package}", [self.selected_id]); self.app.commit_changes()
            self.clear(); self.load(); self.app.status("Registro eliminado.")
        except (oracledb.Error, RuntimeError) as exc: self.app.error(exc)

    def clear(self):
        self.selected_id = None
        for value in self.values.values(): value.set("")
        self.tree.selection_remove(self.tree.selection())


class ArticleTab(ttk.Frame):
    def __init__(self, parent, app):
        super().__init__(parent, padding=18); self.app=app; self.selected_id=None
        self.author, self.categories, self.tags, self.title, self.publish = (tk.StringVar() for _ in range(5))
        form=ttk.LabelFrame(self,text="Articulo",padding=14); form.pack(fill="x")
        for row,label,var in ((0,"ID autor",self.author),(1,"IDs categorias (ej. 1, 3)",self.categories),(2,"IDs etiquetas (ej. 2, 4)",self.tags),(3,"Titulo",self.title)):
            ttk.Label(form,text=label).grid(row=row,column=0,sticky="w",pady=4); ttk.Entry(form,textvariable=var,width=72).grid(row=row,column=1,sticky="ew",pady=4)
        ttk.Label(form,text="Contenido").grid(row=4,column=0,sticky="nw",pady=4); self.body=tk.Text(form,height=7,width=62,wrap="word",bg="#101010",fg="#f5f5f5",insertbackground="#f5f5f5",relief="flat"); self.body.grid(row=4,column=1,sticky="ew",pady=4)
        ttk.Checkbutton(form,text="Publicar ahora",variable=self.publish,onvalue="1",offvalue="0").grid(row=5,column=1,sticky="w")
        buttons=ttk.Frame(form); buttons.grid(row=6,column=1,sticky="w",pady=(12,0))
        for label,cmd,style in (("Nuevo",self.clear,"TButton"),("Guardar",self.save,"Accent.TButton"),("Eliminar",self.delete,"Danger.TButton")):
            ttk.Button(buttons,text=label,command=cmd,style=style).pack(side="left",padx=(0,8))
        self.tree=ttk.Treeview(self,columns=("ID","Titulo","Autor","Categoria","Publicado"),show="headings",height=13)
        for column,width in zip(self.tree["columns"],(75,340,120,130,150)): self.tree.heading(column,text=column); self.tree.column(column,width=width)
        self.tree.pack(fill="both",expand=True,pady=(16,0)); self.tree.bind("<<TreeviewSelect>>",self.select)

    def load(self):
        if not self.app.conn:return
        rows=self.app.query("SELECT a.Article_Id,a.Title,u.Full_Name,NVL((SELECT LISTAGG(c.Name, ', ') WITHIN GROUP (ORDER BY c.Name) FROM Blog_Article_Categories ac JOIN Blog_Categories c ON c.Category_Id=ac.Category_Id WHERE ac.Article_Id=a.Article_Id),'Sin categoria'),NVL(TO_CHAR(a.Published_At,'YYYY-MM-DD HH24:MI'),'Borrador') FROM Blog_Articles a JOIN Blog_Users u ON u.User_Id=a.Author_Id ORDER BY a.Article_Id DESC")
        self.tree.delete(*self.tree.get_children()); [self.tree.insert("","end",values=row) for row in rows]

    def select(self,_=None):
        selected=self.tree.selection()
        if not selected:return
        self.selected_id=int(self.tree.item(selected[0],"values")[0])
        row=self.app.query("SELECT Author_Id,Title,Body,CASE WHEN Published_At IS NULL THEN 0 ELSE 1 END FROM Blog_Articles WHERE Article_Id=:id",id=self.selected_id)[0]
        categories=self.app.query("SELECT Category_Id FROM Blog_Article_Categories WHERE Article_Id=:id ORDER BY Category_Id",id=self.selected_id)
        tags=self.app.query("SELECT Tag_Id FROM Blog_Article_Tags WHERE Article_Id=:id ORDER BY Tag_Id",id=self.selected_id)
        self.author.set(row[0]); self.categories.set(", ".join(str(x[0]) for x in categories)); self.tags.set(", ".join(str(x[0]) for x in tags)); self.title.set(row[1]); self.body.delete("1.0","end"); self.body.insert("1.0",row[2]); self.publish.set(str(row[3]))

    def id_list(self, value, label):
        if not value.strip(): return []
        parts=[item.strip() for item in value.split(",")]
        if any(not item for item in parts): raise ValidationError(f"{label} no puede contener comas vacías.")
        result=[number(item,label) for item in parts]
        if len(set(result)) != len(result): raise ValidationError(f"{label} no puede repetir IDs.")
        return result

    def data(self):
        return [number(self.author.get(),"ID de autor"),text(self.title.get(),"Titulo",180),text(self.body.get("1.0","end-1c"),"Contenido",10000),int(self.publish.get() or 0)]

    def replace_relations(self, article_id):
        self.app.call("Blog_Pkg.clear_tags",[article_id]); self.app.call("Blog_Pkg.clear_categories",[article_id])
        for tag_id in self.id_list(self.tags.get(),"ID de etiqueta"): self.app.call("Blog_Pkg.assign_tag",[article_id,tag_id])
        for category_id in self.id_list(self.categories.get(),"ID de categoria"): self.app.call("Blog_Pkg.assign_category",[article_id,category_id])

    def save(self):
        try:
            data=self.data()
            self.id_list(self.tags.get(),"ID de etiqueta"); self.id_list(self.categories.get(),"ID de categoria")
            if self.selected_id is None:
                article_id=self.app.call_create("Blog_Pkg.create_article",data); self.app.status(f"Articulo creado con ID {article_id}.")
            else: self.app.call("Blog_Pkg.update_article",[self.selected_id]+data); article_id=self.selected_id; self.app.status("Articulo actualizado.")
            self.replace_relations(article_id)
            self.app.commit_changes(); self.clear(); self.load()
        except (ValidationError,oracledb.Error,RuntimeError) as exc:self.app.error(exc)

    def delete(self):
        if self.selected_id is None:return self.app.warn("Selecciona un articulo para eliminar.")
        if not messagebox.askyesno("Confirmar eliminación","Esto eliminará también sus comentarios y etiquetas.",parent=self):return
        try:self.app.call("Blog_Pkg.delete_article",[self.selected_id]);self.app.commit_changes();self.clear();self.load();self.app.status("Articulo eliminado.")
        except (oracledb.Error,RuntimeError) as exc:self.app.error(exc)

    def clear(self):
        self.selected_id=None; self.author.set("");self.categories.set("");self.tags.set("");self.title.set("");self.publish.set("0");self.body.delete("1.0","end");self.tree.selection_remove(self.tree.selection())


class CommentTab(ttk.Frame):
    def __init__(self, parent, app):
        super().__init__(parent, padding=18); self.app=app; self.selected_id=None
        self.article,self.user=tk.StringVar(),tk.StringVar()
        form=ttk.LabelFrame(self,text="Comentario",padding=14);form.pack(fill="x")
        for row,label,var in ((0,"ID articulo",self.article),(1,"ID usuario",self.user)):
            ttk.Label(form,text=label).grid(row=row,column=0,sticky="w",pady=4);ttk.Entry(form,textvariable=var,width=60).grid(row=row,column=1,sticky="ew",pady=4)
        ttk.Label(form,text="Comentario").grid(row=2,column=0,sticky="nw",pady=4);self.body=tk.Text(form,height=5,width=55,wrap="word",bg="#101010",fg="#f5f5f5",insertbackground="#f5f5f5",relief="flat");self.body.grid(row=2,column=1,sticky="ew",pady=4)
        buttons=ttk.Frame(form);buttons.grid(row=3,column=1,sticky="w",pady=(12,0))
        for label,cmd,style in (("Nuevo",self.clear,"TButton"),("Guardar",self.save,"Accent.TButton"),("Eliminar",self.delete,"Danger.TButton")):
            ttk.Button(buttons,text=label,command=cmd,style=style).pack(side="left",padx=(0,8))
        self.tree=ttk.Treeview(self,columns=("ID","Articulo","Usuario","Comentario","Fecha"),show="headings",height=14)
        for name,width in zip(self.tree["columns"],(75,260,190,350,150)):self.tree.heading(name,text=name);self.tree.column(name,width=width)
        self.tree.pack(fill="both",expand=True,pady=(16,0));self.tree.bind("<<TreeviewSelect>>",self.select)

    def load(self):
        if not self.app.conn:return
        rows=self.app.query("SELECT c.Comment_Id,a.Title,u.Full_Name,c.Body,TO_CHAR(c.Created_At,'YYYY-MM-DD HH24:MI') FROM Blog_Comments c JOIN Blog_Articles a ON a.Article_Id=c.Article_Id JOIN Blog_Users u ON u.User_Id=c.User_Id ORDER BY c.Comment_Id DESC")
        self.tree.delete(*self.tree.get_children());[self.tree.insert("","end",values=row) for row in rows]

    def select(self,_=None):
        selected=self.tree.selection()
        if not selected:return
        self.selected_id=int(self.tree.item(selected[0],"values")[0]);row=self.app.query("SELECT Article_Id,User_Id,Body FROM Blog_Comments WHERE Comment_Id=:id",id=self.selected_id)[0]
        self.article.set(row[0]);self.user.set(row[1]);self.body.delete("1.0","end");self.body.insert("1.0",row[2])

    def save(self):
        try:
            article=number(self.article.get(),"ID de articulo");user=number(self.user.get(),"ID de usuario");body=text(self.body.get("1.0","end-1c"),"Comentario",MAX_TEXT,3)
            if self.selected_id is None:
                new_id=self.app.call_create("Blog_Pkg.create_comment",[article,user,body]);self.app.status(f"Comentario creado con ID {new_id}.")
            else:self.app.call("Blog_Pkg.update_comment",[self.selected_id,body]);self.app.status("Comentario actualizado.")
            self.app.commit_changes();self.clear();self.load()
        except (ValidationError,oracledb.Error,RuntimeError) as exc:self.app.error(exc)

    def delete(self):
        if self.selected_id is None:return self.app.warn("Selecciona un comentario para eliminar.")
        if not messagebox.askyesno("Confirmar eliminación","¿Eliminar el comentario seleccionado?",parent=self):return
        try:self.app.call("Blog_Pkg.delete_comment",[self.selected_id]);self.app.commit_changes();self.clear();self.load();self.app.status("Comentario eliminado.")
        except (oracledb.Error,RuntimeError) as exc:self.app.error(exc)

    def clear(self):
        self.selected_id=None;self.article.set("");self.user.set("");self.body.delete("1.0","end");self.tree.selection_remove(self.tree.selection())


class BlogApp(tk.Tk):
    def __init__(self):
        super().__init__(); self.conn: Any | None = None; self.title("Blog Oracle - Administrador"); self.minsize(940,650); self.configure(bg="#000000"); self.setup_style()
        top=ttk.Frame(self,padding=(22,16));top.pack(fill="x")
        ttk.Label(top,text="BLOG ORACLE",style="Title.TLabel").pack(side="left")
        self.connection_label=ttk.Label(top,text="Sin conexión",style="Hint.TLabel");self.connection_label.pack(side="left",padx=18)
        ttk.Button(top,text="Conectar",command=lambda:ConnectionDialog(self)).pack(side="right")
        ttk.Button(top,text="Actualizar",command=self.refresh).pack(side="right",padx=8)
        self.notebook=ttk.Notebook(self);self.notebook.pack(fill="both",expand=True,padx=22,pady=(0,8));self.tabs=[]
        for entity in ENTITIES:
            tab=SimpleTab(self.notebook,self,entity);self.tabs.append(tab);self.notebook.add(tab,text=entity.title)
        self.article_tab=ArticleTab(self.notebook,self);self.tabs.append(self.article_tab);self.notebook.add(self.article_tab,text="Articulos")
        self.comment_tab=CommentTab(self.notebook,self);self.tabs.append(self.comment_tab);self.notebook.add(self.comment_tab,text="Comentarios")
        self.status_var=tk.StringVar(value="Conéctate a Oracle para comenzar.");ttk.Label(self,textvariable=self.status_var,style="Status.TLabel",anchor="w",padding=(22,8)).pack(fill="x")
        self.protocol("WM_DELETE_WINDOW",self.close)

    def setup_style(self):
        style=ttk.Style(self);style.theme_use("clam");style.configure(".",background="#000000",foreground="#f5f5f5");style.configure("TFrame",background="#000000");style.configure("TLabelframe",background="#000000",foreground="#f5f5f5");style.configure("TLabelframe.Label",background="#000000",foreground="#f5f5f5");style.configure("TLabel",background="#000000",foreground="#f5f5f5");style.configure("TEntry",fieldbackground="#101010",foreground="#f5f5f5",insertcolor="#f5f5f5");style.configure("TCheckbutton",background="#000000",foreground="#f5f5f5");style.configure("Title.TLabel",font=("Segoe UI",19,"bold"),foreground="#4da3ff",background="#000000");style.configure("Hint.TLabel",foreground="#b6b6b6",background="#000000");style.configure("Status.TLabel",foreground="#d9d9d9",background="#111111");style.configure("TButton",foreground="#f5f5f5",background="#252525",padding=(13,7));style.map("TButton",background=[("active","#3a3a3a")]);style.configure("Accent.TButton",foreground="white",background="#1466b8",padding=(13,7));style.map("Accent.TButton",background=[("active","#1c7bd7")]);style.configure("Danger.TButton",foreground="white",background="#a52a2a",padding=(13,7));style.configure("TNotebook",background="#000000",borderwidth=0);style.configure("TNotebook.Tab",background="#202020",foreground="#f5f5f5",padding=(14,8));style.map("TNotebook.Tab",background=[("selected","#1466b8")],foreground=[("selected","white")]);style.configure("Treeview",rowheight=29,font=("Segoe UI",10),background="#101010",fieldbackground="#101010",foreground="#f5f5f5");style.map("Treeview",background=[("selected","#1466b8")],foreground=[("selected","white")]);style.configure("Treeview.Heading",font=("Segoe UI",10,"bold"),background="#252525",foreground="#f5f5f5")

    def set_connection(self,conn,label):
        if self.conn:
            try:self.conn.close()
            except oracledb.Error:pass
        self.conn=conn;self.connection_label.config(text=label);self.status("Conexión establecida. Las operaciones de escritura usan Blog_Pkg.");self.refresh()

    def connection(self) -> Any:
        # Evita hacer consultas antes de conectarse a Oracle.
        if self.conn is None:
            raise RuntimeError("Primero conecta la aplicación a Oracle.")
        return self.conn

    def query(self,sql,**binds):
        cursor=self.connection().cursor()
        try:cursor.execute(sql,binds);return cursor.fetchall()
        finally:cursor.close()

    def call(self,procedure,params):
        cursor=self.connection().cursor()
        try:cursor.callproc(procedure,params)
        finally:cursor.close()

    def call_create(self, procedure, params) -> int:
        # Ejecuta una alta y obtiene el ID que asignó Oracle.
        cursor=self.connection().cursor()
        try:
            output=cursor.var(int)
            cursor.callproc(procedure,params+[output])
            return int(output.getvalue())
        finally:cursor.close()

    def commit_changes(self):
        self.connection().commit()

    def function(self,name):
        cursor=self.connection().cursor()
        try:return cursor.callfunc(name, int)
        finally:cursor.close()

    def refresh(self):
        if not self.conn:return self.warn("Primero conecta la aplicación a Oracle.")
        try:
            for tab in self.tabs:tab.load()
            articles=self.function("Blog_Pkg.article_count");comments=self.function("Blog_Pkg.comment_count")
            self.status(f"Datos actualizados: {articles} artículo(s) y {comments} comentario(s).")
        except oracledb.Error as exc:self.error(exc)

    def status(self,message):self.status_var.set(message)
    def warn(self,message):messagebox.showwarning("Revisa los datos",message,parent=self)
    def error(self,error):
        if self.conn:
            # Si ocurre un error, no se dejan cambios incompletos guardados.
            try:self.conn.rollback()
            except oracledb.Error:pass
        messagebox.showerror("Operación no realizada",oracle_message(error),parent=self);self.status("La operación fue cancelada; no se enviaron cambios incompletos.")
    def close(self):
        if self.conn:
            try:self.conn.close()
            except oracledb.Error:pass
        self.destroy()


if __name__ == "__main__":
    BlogApp().mainloop()
