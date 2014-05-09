using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace knockbone.Controllers
{
    public class ListItemController : Controller
    {
        //
        // GET: /ItemList/

        public JsonResult GetAll(string listID)
        {
            
            Dictionary<string, List<ListItemM>> Lists = null;
            if(Session["lists"] !=null)
            {
                Lists = (Dictionary<string, List<ListItemM>>) Session["lists"];
                
            }
            else
            {
                Lists = new Dictionary<string, List<ListItemM>>();
                
            }

            var Items = new List<ListItemM>();
            
            foreach (string thisKey in Lists.Keys)
            {
                if (thisKey == listID)
                {
                    Items = Lists[thisKey];
                }
            }

            var results = Items.Select(p => new
                {
                    listID = p.listID,
                    listItemID = p.listItemID.ToString(),
                    dateAdded = p.dateAdded == null ? null : p.dateAdded.ToString(),
                    dateComplete = p.dateComplete == null ? null : p.dateComplete.ToString(),
                    bComplete = p.bComplete,
                    text = p.text

                }).ToList();
            return Json(new { result = "success", items = results }, JsonRequestBehavior.AllowGet);

        }

        public JsonResult Save(string listID, string listItemID, string dateAdded, string text, string dateComplete, bool? bComplete)
        {

            Dictionary<string, List<ListItemM>> Lists = null;
            if (Session["lists"] != null)
            {
                Lists = (Dictionary<string, List<ListItemM>>)Session["lists"];

            }
            else
            {
                Lists = new Dictionary<string, List<ListItemM>>();

            }

            var Items = new List<ListItemM>();

            foreach (string thisKey in Lists.Keys)
            {
                if (thisKey == listID)
                {
                    Items = Lists[thisKey];
                }
            }

            var thisItem = Items.FirstOrDefault(p => p.listItemID == new Guid(listItemID));

            if (thisItem == null)
            {
                thisItem = new ListItemM()
                    {
                        listID= listID,
                        listItemID = new Guid(listItemID),
                        dateAdded = dateAdded == null ? null : (DateTime?)DateTime.Parse(dateAdded),
                        dateComplete = dateComplete == null ? null : (DateTime?)DateTime.Parse(dateComplete),
                        bComplete = bComplete == null ? null : (bool?)bComplete.Value,
                        text = text
                    };
                Items.Add(thisItem);
            }
            else
            {
                thisItem.listID = listID;
                thisItem.listItemID = new Guid(listItemID);
                thisItem.dateAdded = dateAdded == null ? null : (DateTime?)DateTime.Parse(dateAdded);
                thisItem.dateComplete = dateComplete == null ? null : (DateTime?)DateTime.Parse(dateComplete);
                thisItem.bComplete = bComplete == null ? null : (bool?)bComplete.Value;
                thisItem.text = text;

            }
            Lists[listID] = Items;
            Session["lists"] = Lists;
            return Json(new { result = "success", item = thisItem }, JsonRequestBehavior.AllowGet);

        }

    }

    public class ListItemM
    {
        public string listID { get; set; }
        public Guid listItemID { get; set; }
        public DateTime? dateAdded { get; set; }
        public DateTime? dateComplete { get; set; }
        public bool? bComplete { get; set; }
        public string text { get; set; }

    }
}
