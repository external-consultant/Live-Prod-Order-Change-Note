Report 81180 "Update Latest PCN"
{
    ProcessingOnly = true;
    Description = 'T12149';


    dataset
    {
        dataitem("Prod. Order Change Note Header"; "Prod. Order Change Note Header")
        {
            DataItemTableView = sorting("No.") where(Posted = const(true));


            trigger OnAfterGetRecord()
            var
                ProductionOrder_lRec: Record "Production Order";
            begin
                //T12712-NS
                ProductionOrder_lRec.Reset;
                ProductionOrder_lRec.SetRange("No.", "Prod. Order No.");
                if ProductionOrder_lRec.FindFirst then begin
                    ProductionOrder_lRec."Latest PCN No." := "No.";
                    ProductionOrder_lRec."Total No. of PCN Posted" += 1;
                    ProductionOrder_lRec.Modify;
                end;
                //T12712-NE
            end;

            trigger OnPreDataItem()
            begin
                SetCurrentkey("Posted On");
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Message('Done');
    end;
}

